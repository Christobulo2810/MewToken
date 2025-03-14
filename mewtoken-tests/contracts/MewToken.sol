// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract MewToken is ERC20, Ownable, Pausable {
    // Límite máximo de tokens (9,999,999 MEW)
    uint256 public constant MAX_SUPPLY = 9_999_999 * 10**18;

    // Eventos para rastrear mint y burn
    event TokensBurned(address indexed account, uint256 amount);
    event TokensMinted(address indexed to, uint256 amount);

    // Constructor
    constructor() ERC20("MewToken", "MEW") Ownable() {}

    // Función para acuñar tokens con límite máximo
    function mint(address to, uint256 amount) external onlyOwner whenNotPaused {
        require(totalSupply() + amount <= MAX_SUPPLY, "MewToken: Excede el suministro maximo");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    // Función para quemar tokens
    function burn(uint256 amount) external whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "MewToken: saldo insuficiente para quemar");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    // Función para quemar tokens con allowance
    function burnFrom(address account, uint256 amount) external whenNotPaused {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
        emit TokensBurned(account, amount);
    }

    // Función para pausar todas las transferencias
    function pause() external onlyOwner {
        require(!paused(), "MewToken: ya esta pausado");
        _pause();
    }

    // Función para reanudar transferencias
    function unpause() external onlyOwner {
        require(paused(), "MewToken: ya esta activo");
        _unpause();
    }

    // Validar pausas antes de transferencias
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(!paused(), "MewToken: Las transferencias estan pausadas");
        super._beforeTokenTransfer(from, to, amount);
    }
}