pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SoldTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;
  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
      uint tokens = msg.value * tokensPerEth;
      yourToken.transfer(msg.sender, tokens);
      emit BuyTokens(msg.sender, msg.value, tokens);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner{
      uint256 ownerBalance = address(this).balance;
      require(ownerBalance > 0, "Owner has not balance to withdraw");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send user balance back to the owner");
  }

  function approve(uint256 tokens) public returns (bool) {
    return yourToken.approve(address(this), tokens);
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 tokenAmountToSell) public {
      // Check that the requested amount of tokens to sell is more than 0
      require(tokenAmountToSell > 0, "Specify an amount of token greater than zero");

      // Check that the user's token balance is enough to do the swap
      uint256 userBalance = yourToken.balanceOf(msg.sender);
      require(userBalance >= tokenAmountToSell, "Your balance is lower than the amount of tokens you want to sell");

      // Check that the Vendor's balance is enough to do the swap
      uint256 amountOfETHToTransfer = tokenAmountToSell / tokensPerEth;
      uint256 ownerETHBalance = address(this).balance;
      require(ownerETHBalance >= amountOfETHToTransfer, "Vendor has not enough funds to accept the sell request");
      // yourToken.approve(address(this), tokenAmountToSell);
      (bool sent) = yourToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
      require(sent, "Failed to transfer tokxens from user to vendor");


      (sent,) = msg.sender.call{value: amountOfETHToTransfer}("");
      require(sent, "Failed to send ETH to the user");
      emit SoldTokens(msg.sender, amountOfETHToTransfer, tokenAmountToSell);
  }

}
