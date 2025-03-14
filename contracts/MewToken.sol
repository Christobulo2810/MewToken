// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importamos las bibliotecas de OpenZeppelin para seguridad y estándares ERC-20
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract MewToken is ERC20, Ownable, Pausable {
    // Eventos para facilitar el rastreo de operaciones
    event TokensBurned(address indexed account, uint256 amount);
    event TokensMinted(address indexed to, uint256 amount);

    // Constructor: Inicializa el token con un nombre, símbolo y oferta inicial
    constructor() ERC20("MewToken", "MEW") Ownable() {
        // No se mintean tokens al inicio, se usa la función mint() para distribuir según demanda // Minting de los tokens iniciales
    }

    // Función para quemar tokens (cualquiera puede quemar sus propios tokens)
    function burn(uint256 amount) external whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "MewToken: saldo insuficiente para quemar");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    // Función para quemar tokens con allowance (permiso de otro usuario)
    function burnFrom(address account, uint256 amount) external whenNotPaused {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
        emit TokensBurned(account, amount);
    }

    // Función para acuñar tokens (solo el propietario puede hacerlo)
    function mint(address to, uint256 amount) external onlyOwner whenNotPaused {
        require(to != address(0), "MewToken: no se puede mintear a la direccion cero");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    // Función para pausar todas las transferencias (solo el propietario puede pausar)
    function pause() external onlyOwner {
        require(!paused(), "MewToken: ya esta pausado");
        _pause();
    }

    // Función para reanudar las transferencias (solo el propietario puede reanudar)
    function unpause() external onlyOwner {
        require(paused(), "MewToken: ya esta activo");
        _unpause();
    }

    // Sobrescribimos la función _beforeTokenTransfer para incluir la lógica de pausa
    function _update(address from, address to, uint256 amount) internal override {
        require(!paused(), "MewToken: Las transferencias estan pausadas");
        super._update(from, to, amount);
    }
}
