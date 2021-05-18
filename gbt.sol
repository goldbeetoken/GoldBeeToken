
/**
 * 
 *  🥇🐝 Gold Bee Token 🐝🥇
 * 
 *  A BSC deflationary token with LOTTERY and CHARITY support.
 *  
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  
 * 
 *  Total Supply            21,000,000
 * 
 *  At each transaction:
 *  - %1 is burnt
 *  - %2 is goes to lottery pool
 *  - %2 is goes to charity wallet
 *  
 *  Set slippage to         6% - 10%
 *
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  
 *  Telegram : https://t.me/goldbeetoken
 * 
 */
 
pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

// pragma solidity >=0.5.0;
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// pragma solidity >=0.6.2;
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract GoldBeeToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    address[] private _excluded;
    
    address [] private _holders;
    mapping(address => bool) private _addedToHolders;
    mapping(address => uint256) private _holderIndex;
    
    address [] private _blacklist;
    mapping(address => bool) private _blacklistHolders;
    mapping(address => uint256) private _blacklistIndex;
   
    uint256 private _totalSupply = 21 * 10**6 * 10**9;
    uint256 private _tBurnTotal;

    string private _name = "Gold Bee Token";
    string private _symbol = "GBT";
    uint8 private _decimals = 9;
    
    uint256 public _burnFee = 1;
    uint256 public _charityFee = 2;
    uint256 public _lotteryFee = 2;
    
    uint256 private _previousBurnFee = _burnFee;
    uint256 private _previousCharityFee = _charityFee;
    uint256 private _previousLotteryFee = _lotteryFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public lotteryAddress;
    address private charityWallet ;
    
    bool inSwapAndSendCharity;
    bool public SwapAndSendCharityEnabled = true;
    
    uint256 public _maxTxAmount = 21 * 10**6 * 10**9;
    uint256 private numTokensSellToAddToCharity = 2 * 10**4 * 10**9;
    uint256 public winningAmount = 1 * 10**6 * 10**9;
    uint256 public minimumHold = 1 * 10**4 * 10**9;
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndSendCharityEnabledUpdated(bool enabled);
    event SwapAndSendCharity(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndSendCharity = true;
        _;
        inSwapAndSendCharity = false;
    }
    
    address private constant _addressUniswapV2Router02 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor () public {
        _balances[_msgSender()] = _totalSupply;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_addressUniswapV2Router02);

         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        //exclude addres from lotteryholder
        _addtoblacklist(address(0));
        _addtoblacklist(owner());
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        uint256 newValue = _allowances[msg.sender][spender].add(addedValue);
        _allowances[msg.sender][spender] = newValue;
        emit Approval(msg.sender, spender, newValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {        
        uint256 newValue = _allowances[msg.sender][spender].sub(subtractedValue);
        _allowances[msg.sender][spender] = newValue;
        emit Approval(msg.sender, spender, newValue);
        return true;
    }

    function isQualifiedForLottery(address account) public view returns(bool) {
        return _addedToHolders[account];
    }
    
    function isBlacklist(address account) public view returns(bool) {
        return _blacklistHolders[account];
    }

    function totalBurn() public view returns (uint256) {
        return _tBurnTotal;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setCharityFeePercent(uint256 CharityFee) external onlyOwner() {
        _charityFee = CharityFee;
    }
    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }
    
    function setLotteryFee (uint256 lotteryfee) external onlyOwner() {
        _lotteryFee = lotteryfee;
    }
    
    function setMinimumHold (uint256 amount) external onlyOwner() {
        minimumHold = amount;
    } 
    
    function setWinningAmount (uint256 winningamount) external onlyOwner() {
        winningAmount = winningamount;
    }
    
    //remove lotteryAddress and router address from lotteryholder
    function setLotteryAddress (address lotteryAddr) external onlyOwner() {
        lotteryAddress = lotteryAddr;
        _addtoblacklist(lotteryAddress);
        _addtoblacklist(uniswapV2Pair);
    }
    
    function _addtoblacklist (address addr) private {
        _blacklist.push(addr);
        _blacklistHolders[addr] = true;
        _blacklistIndex[addr] = _blacklist.length - 1;
    }
    
    function addtoblacklist (address addr) external onlyOwner() {
        _addtoblacklist (addr);
    }
    
    function removeFromBlacklist (address addr) external onlyOwner() {
        _blacklist[_blacklistIndex[addr]] = _blacklist[_blacklist.length -1];
        _blacklist.pop();
        _blacklistHolders[addr] = false;
    }

    function setNumTokensSellToAddToCharity(uint256 _numTokensSellToAddToCharity) external onlyOwner() {
        numTokensSellToAddToCharity = _numTokensSellToAddToCharity;
    }

    function setSwapAndSendCharityEnabled(bool _enabled) external onlyOwner {
        SwapAndSendCharityEnabled = _enabled;
        emit SwapAndSendCharityEnabledUpdated(_enabled);
    }

    function _setBurnFee(uint256 burnFee) external onlyOwner() {
        _burnFee = burnFee;
    }
    
    function _addToHolders(address addr) private {
        if(!_addedToHolders[addr] && _balances[addr] >= minimumHold && !_blacklistHolders[addr]) {
            _holders.push(addr);
            _addedToHolders[addr] = true;
            _holderIndex[addr] = _holders.length - 1;
        }
    }

    function _removeFromHolders(address addr) private {
        if(_balances[addr] <= minimumHold) {
            _holders[_holderIndex[addr]] = _holders[_holders.length -1];
            _holders.pop();
            _addedToHolders[addr] = false;
        }
    }
    
    //to receive ETH from uniswapV2Router when swaping
    receive() external payable {}

    
    function _getPercent(uint256 amount, uint256 percent) private pure returns(uint256) {
        return amount.div(100).mul(percent);
    }
    
    function removeAllFee() private {
        if(_charityFee == 0 && _burnFee == 0) return;
        
        _previousBurnFee = _burnFee;
        _previousCharityFee = _charityFee;
        _previousLotteryFee = _lotteryFee;
        
        _burnFee = 0;
        _charityFee = 0;
        _lotteryFee = 0;
    }
    
    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _charityFee = _previousCharityFee;
        _lotteryFee = _previousLotteryFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function CharityWalletAddress() public view returns (address) {
        return charityWallet;
    }
    
    function setCharityWallet(address _charityWallet) external onlyOwner(){
        charityWallet = charityWallet;
        _addtoblacklist(_charityWallet);
    }

    function SwapAndCharity(uint256 contractTokenBalance) private lockTheSwap {
        // swap tokens for bnb
        swapTokensForBNB(contractTokenBalance); // <- this breaks the bnb -> HATE swap when swap+liquify is triggered

        // how much bnb in contract balance
        uint256 BNBbalance = address(this).balance;

        // transfer charityFund to charityWallet
        _charityTransfer(charityWallet, BNBbalance);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    event charityTransfer(address recipient, uint256 ethAmount);
    
    function _charityTransfer(address recipient, uint256 amount) private {
        
        emit charityTransfer(recipient, amount);
        // Transfer eth balance
        (bool sent,) = recipient.call{value : amount}("");
        require(sent, 'Error: Cannot Transfer Charity');
    }  

    function _transferToCharity(uint256 amount) private {
        _balances[address(this)] = _balances[address(this)].add(amount);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + Charity lock?
        // also, don't get caught in a circular Charity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToCharity;
        if (
            overMinTokenBalance &&
            !inSwapAndSendCharity &&
            from != uniswapV2Pair &&
            SwapAndSendCharityEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToCharity;
            SwapAndCharity(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        _tokenTransfer(from,to,amount,takeFee);
    }
    

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        uint256 amountToCharity = _getPercent(amount, _charityFee);
        uint256 amountToBurn = _getPercent(amount, _burnFee);
        uint256 amountToLottery = _getPercent(amount, _lotteryFee);
        uint256 amountToTransfer = amount.sub(amountToBurn).sub(amountToCharity).sub(amountToLottery);
        _totalSupply = _totalSupply.sub(amountToBurn);
        _saveTokensForLottery(amountToLottery);
        _transferToCharity(amountToCharity);
        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amountToTransfer);
        
        _sendLotteryReward();
        
        if(!takeFee)
            restoreAllFee();
            
        
        _removeFromHolders(sender);
        _addToHolders(recipient);
        emit Transfer(sender, recipient, amountToTransfer);
    }

    function _saveTokensForLottery(uint256 amount) private {
        _balances[lotteryAddress] = _balances[lotteryAddress].add(amount);
    }
    
    function _sendLotteryReward() private {
        if((_balances[lotteryAddress] >= winningAmount) && (_holders.length > 1)) {
            uint256 length = _holders.length;
            uint256 winnerIndex = _getRandom(length - 1);
            address winner = _holders[winnerIndex];
            lottery lot = lottery(lotteryAddress);
            lot.sendReward(winningAmount, winner);
        }
    }

    function _getRandom(uint256 max) private view returns(uint256) {
        return uint(keccak256(abi.encodePacked(now, msg.sender, block.difficulty))) % (max + 1);
    }
}

contract lottery {
    
    address contract_address;
    
    constructor(address _contractAddress) public {
        contract_address = _contractAddress;
    }
    modifier onlyContract() {
        require(msg.sender == contract_address, "Ownable: caller is not the owner");
        _;
    }

    function sendReward(uint256 amount, address winner) public onlyContract() {
        IERC20(contract_address).transfer(winner, amount);
    }
  
}
