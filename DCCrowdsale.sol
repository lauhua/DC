
pragma solidity ^0.4.16;

interface dhnCoin {
    function superTransfer(address _to, uint256 _value) public;
}

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract DCCrowdsale is owned {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaisedInEthers;
    uint public restExchangeAmount;
    uint public startTime;
    uint public price;
    uint public dcDecimals = 18;
    dhnCoin public dcReward;
    mapping(address => uint256) public balanceInEtherOf;
    bool crowdsaleClosed = false;

    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function DCCrowdsale(
        address ifSuccessfulSendTo,
        uint fundingGoalInDCs,
        uint dcCostOfEachEther,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInDCs;
        startTime = now;

        price = dcCostOfEachEther;
        dcReward = dhnCoin(addressOfTokenUsedAsReward);
        restExchangeAmount = fundingGoal;
    }

    function _bonus(uint256 amount, uint256 exchangeInDCs) constant internal returns (uint256 bonus) {
        bonus = 0;
        
        if(now <= startTime + 3 days) {
            if(amount >= 8000) {
                bonus = exchangeInDCs * 35 / 100;
            } else if(amount >= 5000 && amount < 8000) {
                bonus = exchangeInDCs * 30 / 100;
            } else if(amount >= 3000 && amount < 5000) {
                bonus = exchangeInDCs * 25 / 100;
            } 
        } else if(now <= startTime + 6 days) {
            bonus = exchangeInDCs * 20 / 100;
        } else if(now <= startTime + 10 days) {
            bonus = exchangeInDCs * 15 / 100;
        } else if(now <= startTime + 14 days) {
            bonus = exchangeInDCs * 10 / 100;
        } else if(now <= startTime + 18 days) {
            bonus = exchangeInDCs * 5 / 100;
        }
        
        return bonus;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        require(!crowdsaleClosed);
        uint amountInEthers = msg.value;
        uint amount = amountInEthers / 1 ether;
        uint exchangeInDCs = amount * price;
        require(restExchangeAmount >= exchangeInDCs);
        uint bonus = _bonus(amount, exchangeInDCs);
        exchangeInDCs += bonus; 
        if(restExchangeAmount < exchangeInDCs) {
            exchangeInDCs = restExchangeAmount;
        }
        
        balanceInEtherOf[msg.sender] += amountInEthers;
        amountRaisedInEthers += amountInEthers;
        
        dcReward.superTransfer(msg.sender, exchangeInDCs * 10 ** uint256(dcDecimals));
        restExchangeAmount -= exchangeInDCs;
        FundTransfer(msg.sender, amountInEthers, true);
    }
    
    function pay() payable public {
        require(!crowdsaleClosed);
        uint amountInEthers = msg.value;
        uint amount = amountInEthers / 1 ether;
        uint exchangeInDCs = amount * price;
        require(restExchangeAmount >= exchangeInDCs);
        uint bonus = _bonus(amount, exchangeInDCs);
        exchangeInDCs += bonus; 
        if(restExchangeAmount < exchangeInDCs) {
            exchangeInDCs = restExchangeAmount;
        }
        
        balanceInEtherOf[msg.sender] += amountInEthers;
        amountRaisedInEthers += amountInEthers;
        
        dcReward.superTransfer(msg.sender, exchangeInDCs * 10 ** uint256(dcDecimals));
        restExchangeAmount -= exchangeInDCs;
        FundTransfer(msg.sender, amountInEthers, true);
    }

    function safeWithdrawal() public {
        if (beneficiary == msg.sender) {
            if (beneficiary.send(amountRaisedInEthers)) {
                FundTransfer(beneficiary, amountRaisedInEthers, false);
            } 
        }
    }
    
    function transferBenificiary(address newBenificiary) onlyOwner public {
        beneficiary = newBenificiary;
    }
    
    function switchCrowdsale(bool enabled) onlyOwner public {
        crowdsaleClosed = enabled;
    }
}

