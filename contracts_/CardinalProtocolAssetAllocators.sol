// contracts/AssetAllocator.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/* ========== [IMPORT] ========== */

// /token
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// /utils
import "@openzeppelin/contracts/utils/Counters.sol";


/* ========== [IMPORT] ========== */
import "./interface/ICardinalProtocol.sol";


contract CardinalProtocolAssetAllocators is ERC721Enumerable {

	/* ========== [DEPENDENCIES] ========== */

	using Counters for Counters.Counter;


	/* ========== [STRUCTS] ========== */

	struct StrategyAllocation {
		uint64 id;
		uint8 pct;
	}

	struct Guideline {
		StrategyAllocation[] strategyAllocations;
	}

	/* ========== [STATE-VARIABLES][CONST] ========== */

	address public CARDINAL_PROTOCOL_ADDRESS;


	/* ========== [STATE VARIABLES] ========== */

	// Custom Types
	Counters.Counter public _tokenIdTracker;

	string public _baseTokenURI;
	address public _treasury;

	mapping(uint64 => address) _whitelistedStrategyAddresses;
	mapping(uint256 => Guideline) _guidelines;


	/* ========== [CONTRUCTOR] ========== */

	constructor (
		address cardinalProtocolAddress,
		string memory baseTokenURI,
		address treasury
	) ERC721("Cardinal Protocol Asset Allocators", "CPAA") {
		CARDINAL_PROTOCOL_ADDRESS = cardinalProtocolAddress;

		_baseTokenURI = baseTokenURI;
		_treasury = treasury;
	}

	
	/* ========== [MODIFIERS] ========== */

	modifier auth_owner() {
		// Require that the caller can only by the AssetAllocators Contract
		require(
			msg.sender == ICardinalProtocol(CARDINAL_PROTOCOL_ADDRESS).owner(),
			"!auth"
		);

		_;
	}


	/* ========== [FUNCTION][OVERRIDE][REQUIRED] ========== */
	
	function _burn(uint256 tokenId) internal virtual override(ERC721) {
		// Distribute the tokens that are being yield farmed

		return ERC721._burn(tokenId);
	}

	// Return the full URI of a token
	function tokenURI(uint256 tokenId) public view override(ERC721)
		returns (string memory)
	{
		return ERC721.tokenURI(tokenId);
	}


	/* ========== [FUNCTION][OVERRIDE] ========== */

	function _baseURI() internal view virtual override returns (string memory) {
		return _baseTokenURI;
	}


	/* ========== [FUNCTION][SELF-IMPLEMENTATIONS] ========== */

	function setBaseURI(string memory baseTokenURI) external auth_owner() {
		_baseTokenURI = baseTokenURI;
	}


	/* ========== [FUNCTION] ========== */

	function mint(
		address[] memory toSend,
		Guideline memory guideline_
	) public
	{
		// For each toSend, mint the NFT
		for (uint i = 0; i < toSend.length; i++) {
			// Mint token
			_mint(toSend[i], _tokenIdTracker.current());

			// Add Guideline
			_guidelines[_tokenIdTracker.current()] = guideline_;
			
			// Increment token id
			_tokenIdTracker.increment();
		}
	}

	// To forward any erc20s from this contract, an array of erc20 token addresses
	// will need to be passed
	function depositTokensIntoStrategies(
		uint AssetAllocatorTokenId,
		uint[] memory amounts_
	) public {
		// Check if the wallet owns the assetAllocatorId
		require(
			msg.sender == ownerOf(AssetAllocatorTokenId),
			"You do not own this AssetAllocator token"
		);

		// Retrieve Guideline
		Guideline memory tokenGuideLine = _guidelines[AssetAllocatorTokenId];

		// For each Strategy Allocation
		for (uint i = 0; i < tokenGuideLine.strategyAllocations.length; i++) {
			
		}
	}


	/* ========== [FUNCTION][OTHER] ========== */

	function withdrawToTreasury() public auth_owner() {
		uint balance = address(this).balance;
		
		payable(_treasury).transfer(balance);
	}
}