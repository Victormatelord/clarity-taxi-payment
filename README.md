# Decentralized Taxi Payment System

A blockchain-based payment system for taxi services built on the Stacks network using Clarity.

## Features

- Driver registration system
- Ride management
- Secure payments using STX
- Complete ride tracking
- Payment verification

## How it works

1. Drivers must be registered by the contract owner
2. A ride can be started with a specified fare
3. Only registered drivers can complete rides
4. Passengers can pay for completed rides using STX
5. All transactions are recorded on the blockchain

## Contract Functions

- `register-driver`: Register a new driver (owner only)
- `start-ride`: Start a new ride with fare details
- `complete-ride`: Mark a ride as completed
- `pay-ride`: Process payment for a completed ride
- `get-ride`: Get details of a specific ride
- `is-driver`: Check if an address belongs to a registered driver
