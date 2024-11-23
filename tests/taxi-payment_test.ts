import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Driver registration test",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const driver = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('taxi-payment', 'register-driver', [
                types.principal(driver.address)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk();
        
        let checkDriver = chain.mineBlock([
            Tx.contractCall('taxi-payment', 'is-driver', [
                types.principal(driver.address)
            ], deployer.address)
        ]);
        
        assertEquals(checkDriver.receipts[0].result.expectOk(), types.bool(true));
    }
});

Clarinet.test({
    name: "Complete ride flow test",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const driver = accounts.get('wallet_1')!;
        const passenger = accounts.get('wallet_2')!;
        const fare = 50;
        
        // Register driver
        chain.mineBlock([
            Tx.contractCall('taxi-payment', 'register-driver', [
                types.principal(driver.address)
            ], deployer.address)
        ]);
        
        // Start ride
        let startRide = chain.mineBlock([
            Tx.contractCall('taxi-payment', 'start-ride', [
                types.principal(driver.address),
                types.principal(passenger.address),
                types.uint(fare)
            ], deployer.address)
        ]);
        
        const rideId = 0; // First ride
        
        // Complete ride
        let completeRide = chain.mineBlock([
            Tx.contractCall('taxi-payment', 'complete-ride', [
                types.uint(rideId)
            ], driver.address)
        ]);
        
        completeRide.receipts[0].result.expectOk();
        
        // Pay ride
        let payRide = chain.mineBlock([
            Tx.contractCall('taxi-payment', 'pay-ride', [
                types.uint(rideId)
            ], passenger.address)
        ]);
        
        payRide.receipts[0].result.expectOk();
    }
});
