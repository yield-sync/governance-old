// contracts/CardinalToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/* ========== IMPORTS ========== */

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract Cardinal is ERC20Capped, Pausable {
    /* ========== DEPENDENCIES ========== */

    using SafeERC20 for Cardinal;

    /* ========== EVENTS ========== */

    event SupplyAmountSet(uint amount, address byOwner);

    /* ========== STATE VARIABLES ========== */

    address operator;

    mapping(address => bool) pausers;
    
    /* ========== CONSTRUCTOR ========== */

    constructor ()
        // Token Name and Symbol
        ERC20("Cardinal", "CARD")
        // 100 Million Supply Cap 
        ERC20Capped(100 * 1000000 * 1e18)
    {
        operator = msg.sender;
        pausers[msg.sender] = true;
    }
    
    /* ========== MODIFIERS ========== */

    modifier operatorOnly() { 
        require(msg.sender == operator, "!authorized");

        _;
    }
    
    modifier pauserOnly() {
        require(pausers[msg.sender], "!authorized");

        _;
    }


    /* ========== MUTATIVE FUNCTIONS ========== */

    function mint(
        address _to,
        uint256 _amount
    ) external operatorOnly() whenNotPaused() {
        // Call ERC20Capped "_mint" function
        super._mint(_to, _amount);
    }
    
    function setAsPauser(address[] memory addresses) public operatorOnly() {
        for (uint i = 0; i < addresses.length; ++i) {
            pausers[addresses[i]] = true;
        }
    }

    function pause() public pauserOnly() whenNotPaused() {
        // Call Pausable "_pause" function
        super._pause();
    }

    function unpause() public pauserOnly() whenPaused() {
        // Call Pausable "_unpause" function
        super._unpause();
    }
}