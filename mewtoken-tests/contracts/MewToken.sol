// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MewToken is ERC20, Ownable, Pausable, ReentrancyGuard {
    // Eventos
    event TokensBurned(address indexed account, uint256 amount);
    event TokensMinted(address indexed to, uint256 amount);
    event RewardRateUpdated(uint256 newRewardRate);
    event MaxTransferAmountUpdated(uint256 newMaxTransferAmount);

    // Variables de staking
    mapping(address => uint256) public stakedBalances;
    uint256 public totalStaked;

    // Variables de recompensas
    // rewardRate: cantidad de tokens (con 18 decimales) generados por segundo para el pool
    uint256 public rewardRate = 1e18;  
    // accRewardPerShare: recompensa acumulada por cada token apostado, escalada por 1e12 para precisión
    uint256 public accRewardPerShare;
    // lastRewardTime: último momento de actualización de la pool de recompensas
    uint256 public lastRewardTime;
    // rewardDebt: registro para cada usuario para calcular su recompensa pendiente
    mapping(address => uint256) public rewardDebt;

    // Variables para penalización y límites
    uint256 public minStakingTime = 1 days;
    // Registra el timestamp en el que cada usuario realizó stake
    mapping(address => uint256) public stakeTimestamp;

    // Variable anti-whale: máximo de tokens que se pueden transferir en una operación
    uint256 public maxTransferAmount = 1000 * 10**18; // Ejemplo: 1000 tokens

    // Constructor: se inicializa ERC20 y se pasa msg.sender a Ownable para establecer al propietario.
    constructor() ERC20("MewToken", "MEW") Ownable(msg.sender) {
        lastRewardTime = block.timestamp;
    }

    // ---------------- Funciones de Recompensas y Pool de Staking ----------------

    // updatePool: Actualiza la pool de recompensas basándose en el tiempo transcurrido
    function updatePool() internal {
        if (block.timestamp <= lastRewardTime) {
            return;
        }
        if (totalStaked == 0) {
            lastRewardTime = block.timestamp;
            return;
        }
        uint256 timeElapsed = block.timestamp - lastRewardTime;
        uint256 reward = timeElapsed * rewardRate;
        accRewardPerShare += reward * 1e12 / totalStaked;
        lastRewardTime = block.timestamp;
    }

    // pendingRewards: Consulta las recompensas pendientes para un usuario
    function pendingRewards(address _user) external view returns (uint256) {
        uint256 _accRewardPerShare = accRewardPerShare;
        if (block.timestamp > lastRewardTime && totalStaked != 0) {
            uint256 timeElapsed = block.timestamp - lastRewardTime;
            uint256 reward = timeElapsed * rewardRate;
            _accRewardPerShare += reward * 1e12 / totalStaked;
        }
        return stakedBalances[_user] * _accRewardPerShare / 1e12 - rewardDebt[_user];
    }

    // claimRewards: Permite reclamar recompensas sin modificar el stake
    function claimRewards() external nonReentrant whenNotPaused {
        updatePool();
        uint256 pending = stakedBalances[msg.sender] * accRewardPerShare / 1e12 - rewardDebt[msg.sender];
        require(pending > 0, "No rewards available");
        rewardDebt[msg.sender] = stakedBalances[msg.sender] * accRewardPerShare / 1e12;
        _mint(msg.sender, pending);
    }

    // stake: Permite a un usuario bloquear tokens y acumular recompensas
    function stake(uint256 amount) external whenNotPaused nonReentrant {
        require(balanceOf(msg.sender) >= amount, "No tienes suficientes tokens para stake");
        updatePool();
        if (stakedBalances[msg.sender] > 0) {
            uint256 pending = stakedBalances[msg.sender] * accRewardPerShare / 1e12 - rewardDebt[msg.sender];
            if (pending > 0) {
                _mint(msg.sender, pending);
            }
        }
        _transfer(msg.sender, address(this), amount);
        stakedBalances[msg.sender] += amount;
        totalStaked += amount;
        stakeTimestamp[msg.sender] = block.timestamp;
        rewardDebt[msg.sender] = stakedBalances[msg.sender] * accRewardPerShare / 1e12;
    }

    // unstake: Permite retirar tokens apostados, reclamando recompensas y aplicando penalización si es temprano
    function unstake(uint256 amount) external whenNotPaused nonReentrant {
        require(stakedBalances[msg.sender] >= amount, "No tienes suficientes tokens en staking");
        updatePool();
        uint256 pending = stakedBalances[msg.sender] * accRewardPerShare / 1e12 - rewardDebt[msg.sender];
        if (pending > 0) {
            _mint(msg.sender, pending);
        }
        // Aplicar penalización si se retira antes de minStakingTime
        if (block.timestamp < stakeTimestamp[msg.sender] + minStakingTime) {
            uint256 penalty = (amount * 10) / 100; // 10% de penalización
            amount = amount - penalty;
            _burn(address(this), penalty);
        }
        stakedBalances[msg.sender] -= amount;
        totalStaked -= amount;
        _transfer(address(this), msg.sender, amount);
        rewardDebt[msg.sender] = stakedBalances[msg.sender] * accRewardPerShare / 1e12;
    }

    // ---------------- Funciones Básicas del Token ----------------

    function burn(uint256 amount) external whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "Saldo insuficiente para quemar");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external whenNotPaused {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
        emit TokensBurned(account, amount);
    }

    function mint(address to, uint256 amount) external onlyOwner whenNotPaused {
        require(to != address(0), "No se puede mintear a la direccion cero");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    function pause() external onlyOwner {
        require(!paused(), "El contrato ya esta pausado");
        _pause();
    }

    function unpause() external onlyOwner {
        require(paused(), "El contrato no esta pausado");
        _unpause();
    }

    // ---------------- Funciones de Transferencia con Límite Anti-Whale ----------------

    // Sobrescribimos transfer para incluir verificación de pausa y límite de transferencia
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!paused(), "Las transferencias estan pausadas");
        require(amount <= maxTransferAmount, "Exceeds max transfer amount");
        return super.transfer(recipient, amount);
    }

    // Sobrescribimos transferFrom para incluir verificación de pausa y límite de transferencia
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!paused(), "Las transferencias estan pausadas");
        require(amount <= maxTransferAmount, "Exceeds max transfer amount");
        return super.transferFrom(sender, recipient, amount);
    }

    // Función para actualizar el límite máximo de transferencia (anti-whale)
    function setMaxTransferAmount(uint256 _maxAmount) external onlyOwner {
        maxTransferAmount = _maxAmount;
        emit MaxTransferAmountUpdated(_maxAmount);
    }

    // Función para actualizar la tasa de recompensas
    function setRewardRate(uint256 _newRewardRate) external onlyOwner {
        updatePool();
        rewardRate = _newRewardRate;
        emit RewardRateUpdated(_newRewardRate);
    }
}
