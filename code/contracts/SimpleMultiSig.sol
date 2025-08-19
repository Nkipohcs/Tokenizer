// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * SimpleMultiSig (2-of-3) minimal:
 * - Owners are set at deployment (3 unique, non-zero addresses).
 * - Any owner can submit a transaction (target, value, data).
 * - Requires 2 confirmations to execute.
 * - No reentrancy risk: the external call is the final action of execute().
 * - Gas-friendly: simple mappings, no loops over unbounded arrays on hot paths.
 */

contract SimpleMultiSig {
    error NotOwner();
    error AlreadyConfirmed();
    error NotEnoughConfirmations();
    error TxAlreadyExecuted();
    error InvalidOwners();

    event Submit(bytes32 indexed txId, address indexed proposer, address target, uint256 value, bytes data);
    event Confirm(bytes32 indexed txId, address indexed confirmer, uint256 confirmations);
    event Execute(bytes32 indexed txId, bool success, bytes returnData);

    mapping(address => bool) public isOwner;
    address[3] public owners;
    uint256 public constant REQUIRED = 2;

    struct Tx {
        address target;
        uint256 value;
        bytes data;
        uint8 confirmations; // up to 3
        bool executed;
    }

    mapping(bytes32 => Tx) public txs;
    mapping(bytes32 => mapping(address => bool)) public confirmed;

    constructor(address[3] memory _owners) {
        // Validate owners (3 distinct non-zero)
        if (_owners[0] == address(0) || _owners[1] == address(0) || _owners[2] == address(0)) revert InvalidOwners();
        if (_owners[0] == _owners[1] || _owners[0] == _owners[2] || _owners[1] == _owners[2]) revert InvalidOwners();

        owners = _owners;
        isOwner[_owners[0]] = true;
        isOwner[_owners[1]] = true;
        isOwner[_owners[2]] = true;
    }

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    function computeTxId(address target, uint256 value, bytes calldata data) public view returns (bytes32) {
        return keccak256(abi.encode(address(this), target, value, data, block.chainid));
    }

    function submit(address target, uint256 value, bytes calldata data) external onlyOwner returns (bytes32 txId) {
        txId = computeTxId(target, value, data);
        Tx storage t = txs[txId];
        if (t.target == address(0)) {
            t.target = target;
            t.value = value;
            t.data = data;
            emit Submit(txId, msg.sender, target, value, data);
        }
        _confirm(txId);
    }

    function confirm(bytes32 txId) external onlyOwner {
        _confirm(txId);
    }

    function _confirm(bytes32 txId) internal {
        Tx storage t = txs[txId];
        if (t.executed) revert TxAlreadyExecuted();
        if (confirmed[txId][msg.sender]) revert AlreadyConfirmed();
        confirmed[txId][msg.sender] = true;
        unchecked { t.confirmations += 1; } // safe (max 3)
        emit Confirm(txId, msg.sender, t.confirmations);
    }

    function execute(bytes32 txId) external onlyOwner returns (bool ok, bytes memory ret) {
        Tx storage t = txs[txId];
        if (t.executed) revert TxAlreadyExecuted();
        if (t.confirmations < REQUIRED) revert NotEnoughConfirmations();
        t.executed = true;

        // External call is final action; no state writes after
        (ok, ret) = t.target.call{value: t.value}(t.data);
        emit Execute(txId, ok, ret);
    }

    receive() external payable {}
}
