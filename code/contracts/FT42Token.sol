// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * FT42Token — BEP-20 (ERC-20 compatible) with:
 * - Capped supply
 * - Pausable transfers
 * - Burnable
 * - Ownable (owner can mint within cap, pause/unpause, transfer ownership)
 * - Rescue function for foreign ERC20 (excluding this token)
 *
 * Security notes:
 * - No payable functions
 * - No external calls in critical paths (except rescue which is owner-only)
 * - Uses OZ 4.9.x stable APIs
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FT42Token is ERC20, ERC20Capped, ERC20Burnable, ERC20Pausable, Ownable {
    using SafeERC20 for IERC20;

    /// @notice Prevent rescuing this token itself
    error CannotRescueThisToken();

    /**
     * @param initialOwner      Owner address (admin)
     * @param initialSupply     Initial supply (wei, 18 decimals)
     * @param supplyCap         Max total supply (wei, 18 decimals)
     * @dev Reverts if initialSupply > supplyCap
     */
    constructor(
        address initialOwner,
        uint256 initialSupply,
        uint256 supplyCap
    )
        ERC20("FortyTwo Token", "FT42")
        ERC20Capped(supplyCap)
        // Ownable() is parameter-less in OZ v4.9 and called implicitly.
        // The owner is set to msg.sender (the deployer).
    {
        require(initialOwner != address(0), "Initial owner cannot be zero address");
        // In OZ v4.9, owner is msg.sender. The deploy script passes the deployer as
        // initialOwner, so this check ensures consistency.
        require(initialOwner == msg.sender, "Deployer must be initial owner");
        require(initialSupply <= supplyCap, "Initial supply cannot exceed cap");
        // mint initial supply to owner
        _mint(initialOwner, initialSupply);
    }

    /**
     * @notice Owner can mint new tokens within cap
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @notice Pause transfers (emergencies)
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause transfers
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Rescue ERC20 tokens mistakenly sent to this contract
     * @dev Cannot rescue FT42 itself
     */
    function rescueERC20(address token, address to, uint256 amount) external onlyOwner {
        if (token == address(this)) revert CannotRescueThisToken();
        require(to != address(0), "to=0");
        IERC20(token).safeTransfer(to, amount);
    }

    // --------- Internal overrides (OZ 4.9 style) ----------

    // ERC20Capped overrides _mint to enforce cap; ensure correct override resolution
    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Capped)
    {
        super._mint(to, amount);
    }

    // ERC20Pausable uses _beforeTokenTransfer in OZ 4.9
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
