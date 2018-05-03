
pragma solidity ^0.4.18;

interface DCTToken {
    function transferFrom(address _from, address _to, uint256 _value) external;
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract DCTCandy is Ownable {

    DCTToken public candyOrigin;

    function setCandyOrigin(address candyOriginAddress) public onlyOwner {
        candyOrigin = DCTToken(candyOriginAddress);
    }

    function clearCandyOrigin() public onlyOwner {
        delete candyOrigin;
    }

    function end() public onlyOwner {
        selfdestruct(owner);
    }

    function handoutCandy(address[] candyDest, uint value) public onlyOwner {
        uint len = candyDest.length;
        for(uint i=0; i < len; i ++) {
            candyOrigin.transferFrom(msg.sender, candyDest[i], value);
        }
    }
}