pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FitnessToken is ERC20, Ownable {
    constructor() ERC20("FitnessToken", "FT") {}

    function mint(address recipient, uint256 amount) external onlyOwner {
        _mint(recipient, amount);
    }

    function burnFrom(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}

contract FitnessRewards is Ownable {
    FitnessToken private fitnessToken;

    struct Member {
        uint256 totalAttendedClasses;
        uint256 totalPurchasedServices;
    }

    mapping(address => Member) private members;

    event ClassAttended(
        address indexed member,
        uint256 totalAttendedClasses,
        uint256 totalTokens
    );
    event ServicePurchased(
        address indexed member,
        uint256 totalPurchasedServices,
        uint256 totalTokens
    );
    event RewardRedeemed(address indexed member, uint256 tokensBurned);

    constructor(FitnessToken _fitnessToken) {
        fitnessToken = _fitnessToken;
    }

    function attendClass(address memberAddress) external onlyOwner {
        members[memberAddress].totalAttendedClasses += 1;
        uint256 tokensToMint = 10; // Award 10 FTs for each class
        fitnessToken.mint(memberAddress, tokensToMint);

        emit ClassAttended(
            memberAddress,
            members[memberAddress].totalAttendedClasses,
            tokensToMint
        );
    }

    function purchaseService(address memberAddress) external payable onlyOwner {
        members[memberAddress].totalPurchasedServices += 1;
        uint256 tokensToMint = 50; // Award 50 FTs for each service purchased
        fitnessToken.mint(memberAddress, tokensToMint);

        emit ServicePurchased(
            memberAddress,
            members[memberAddress].totalPurchasedServices,
            tokensToMint
        );
    }

    function redeemRewards(
        address memberAddress,
        uint256 tokenAmount
    ) external {
        require(
            tokenAmount <= fitnessToken.balanceOf(memberAddress),
            "Not enough FTs to redeem"
        );
        fitnessToken.burnFrom(memberAddress, tokenAmount);

        emit RewardRedeemed(memberAddress, tokenAmount);
    }

    function getTotalAttendedClasses(
        address memberAddress
    ) external view returns (uint256) {
        return members[memberAddress].totalAttendedClasses;
    }

    function getTotalPurchasedServices(
        address memberAddress
    ) external view returns (uint256) {
        return members[memberAddress].totalPurchasedServices;
    }
}
