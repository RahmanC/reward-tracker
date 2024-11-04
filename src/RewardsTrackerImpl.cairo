#[starknet::contract]
mod RewardsTracker {
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        balances: LegacyMap::<ContractAddress, u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PointsAdded: PointsAdded,
        PointsRedeemed: PointsRedeemed,
    }

    #[derive(Drop, starknet::Event)]
    struct PointsAdded {
        user: ContractAddress,
        amount: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct PointsRedeemed {
        user: ContractAddress,
        amount: u256,
    }

   

    #[external(v0)]
    impl RewardsTrackerImpl of super::IRewardsTracker<ContractState> {
        fn get_balance(self: @ContractState, user: ContractAddress) -> u256 {
            self.balance.read(user)
        }

        fn add_points(ref self: ContractState, user: ContractAddress, amount: u256) {
            // Only contract owner can add points
            let current_balance = self.balance.read(user);
            self.balance.write(user, current_balance + amount);

            // Emit points added event
            self.emit(Event::PointsAdded(PointsAdded {user, amount}));
        }

        fn redeem_points(ref self: ContractState, amount: u256) {
            let user = get_caller_address();
            let current_balance = self.balance.read(user);

            // Check if user has enough points
            assert(current_balance >= amount, 'Insufficient points');

            // Update balance
            self.balance.write(user, current_balance - amount);

            // EMiy points redeemed event
            self.emit(Event::PointsRedeemed(PointsRedeemed(user, amount))
        }
    }

    #[starknet::interface]
    trait IRewardsTracker<TContractState> {
        fn get_balance(self: @TContractState, user:ContractAddress ) -> u256;
        fn add_points(self: TContractState, user: ContractAddress, amount: u256 );
        fn redeem_points(ref self: TContractState, amount: u256);
    }
}