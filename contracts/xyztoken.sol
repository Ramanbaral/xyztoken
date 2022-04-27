//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XYZToken is ERC20, Ownable {

    event Released(address beneficiary, uint256 amount);

    uint256 _cap = 100_000_000 * 10 ** 18; // 100 Million
    uint256 public start;
    uint256 public duration;

    address[] public beneficiaries;

    constructor() ERC20("XYZToken", "XYZ") {
        start = block.timestamp;
        duration = 525600 minutes; //12 months = 525600 minutes
        beneficiaries.push(0xeB312D70b20D8D683743aeAa728bf803D2B4a36C);
        beneficiaries.push(0x9081be42946d022f295812295f2B1a9726299300);
        beneficiaries.push(0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199);
        beneficiaries.push(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        beneficiaries.push(0xBf575c76180C6d62A40d8455eB2f8c115404f89C);
    }

    modifier onlyBeneficiaries {
        bool isBenificiary;
        for(uint8 i=0; i < beneficiaries.length; i++) {
            if(msg.sender == beneficiaries[i]) {
                isBenificiary = true;
                break;
            }
        }
        require(msg.sender == owner() || isBenificiary, "You cannot release tokens!");
        _;
    }

    function addBeneficiary(address _beneficiary) onlyOwner public {
        require(_beneficiary != address(0), "The beneficiary's address cannot be 0");
        require(beneficiaries.length <= 10, "Only 10 Beneficiaries are allowed");

        releaseAllTokens();

        beneficiaries.push(_beneficiary);
    }

    function releaseAllTokens() onlyBeneficiaries public {
        uint256 unreleased = releasableAmount();
        uint256 unreleasedPerBenficiary = unreleased / beneficiaries.length;

        if (unreleased > 0) {
            uint beneficiariesCount = beneficiaries.length;

            for (uint i = 0; i < beneficiariesCount; i++) {
                release(beneficiaries[i], unreleasedPerBenficiary);
            }
        }
    }

    function releasableAmount() public view returns (uint256) {
        return vestedAmount() - totalSupply();
    }

    function vestedAmount() public view returns (uint256) {
        if (block.timestamp >= start + duration) {
            return _cap;
        } else {
            uint256 timePassedInMinutes = ( block.timestamp - start ) / 60;
            uint256 durationInMinutes = duration / 60;
            return _cap * timePassedInMinutes / durationInMinutes;
        }
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    function release(address _beneficiary, uint256 _amount) private {
        require(totalSupply() + _amount <= _cap, "Supply Capped to 100 Million");
        _mint(_beneficiary, _amount);
        emit Released(_beneficiary, _amount);
    }
    
}