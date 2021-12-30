// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
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

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {

            if (returndata.length > 0) {
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

    constructor () {
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

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

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

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

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

interface IUniswapV2Router02 is IUniswapV2Router01 {

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

contract MetaVice is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _blacklist;
    mapping (address => bool) private _isExcludedFromFee;

    address private taxAddress; // changeable

    uint256 private _totalSupply = 10000000000000 * 10 ** 9;
    string private _name = "Meta-Vice";
    string private _symbol = "MetaVice";
    uint8 private _decimals = 9;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    uint256 public tradeStartTime = 0;

    bool public isTradePaused = false;
    bool public isTradeStarted = false; // all trade is disabled for default
    bool private inSwap = false;

    uint256 public tax = 18; // initial tax 18% for 2 days, will be decreased by 1% per day, until it reaches 8% and stop at 8%
    uint256 public liquidityDivisor = 3;

    uint256 public taxAmount = 0;
    uint256 public liquidityAmount = 0;

    uint256 public feeRate = 2;

    event TradePaused();
    event TradeUnpaused();
    event DrrrStarted();
    event AddedToBlacklist(address account);
    event RemovedFromBlacklist(address account);
    event TaxAddressSet(address account);
    event SwapTokensForETH(uint256 tokenAmount, address[] path, address to);

    modifier lockSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address _taxAddress) {

        taxAddress = _taxAddress;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _balances[_msgSender()] = _totalSupply;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "MetaVice: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "MetaVice: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "MetaVice: approve from the zero address");
        require(spender != address(0), "MetaVice: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function pauseTrade() public onlyOwner {
        require(isTradeStarted == true, "MetaVice: trade is not started");
        require(isTradePaused == false, "MetaVice: already trade paused.");

        isTradePaused = true;
        emit TradePaused();
    }

    function unpauseTrade() public onlyOwner {
        require(isTradeStarted == true, "MetaVice: trade is not started");
        require(isTradePaused == true, "MetaVice: already trade unpaused");

        isTradePaused = false;
        emit TradeUnpaused();
    }

    function swapTokensForEth(uint256 tokenAmount, address to) private {
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
            to,
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path, to);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function addToLiquidity(uint256 amount) private lockSwap {
        uint256 beforeBalance = address(this).balance;
        uint256 tmp = amount.mul(50).div(100);
        uint256 balanceForLiquidity = amount.sub(tmp);
        swapTokensForEth(tmp, address(this));
        uint256 transferredBalance = address(this).balance.sub(beforeBalance);
        // add liquidity to uniswap
        tmp = balanceForLiquidity;
        addLiquidity(tmp, transferredBalance);
    }

    function swapTokens(uint256 amount) private lockSwap {
        swapTokensForEth(amount, taxAddress);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "MetaVice: transfer from the zero address");
        require(to != address(0), "MetaVice: transfer to the zero address");
        require(_blacklist[from] == false, "MetaVice: transfer from blacklisted address.");
        require(_blacklist[to] == false, "MetaVice: transfer to blacklisted address.");
        require(amount > 0, "MetaVice: Transfer amount must be greater than zero");

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            tokenTransfer(from, to, amount);
            return;
        }

        if(from == uniswapV2Pair || to == uniswapV2Pair) {  // buy / sell operation
            require(isTradeStarted == true, "MetaVice: trade is not started");
            require(isTradePaused == false, "MetaVice: trade is paused");

            if(tax > 8) updateTaxFee();

            // convert to ETH and send to tax address
            if(!inSwap && isTradeStarted && taxAmount >= balanceOf(uniswapV2Pair).mul(feeRate).div(100) && to == uniswapV2Pair) {
                uint256 swapAmount = balanceOf(uniswapV2Pair).mul(feeRate).div(100);
                taxAmount = taxAmount.sub(swapAmount);
                swapTokens(swapAmount);
            }

            // add to liquidity
            if(!inSwap && isTradeStarted && liquidityAmount >= balanceOf(uniswapV2Pair).mul(feeRate).div(100) && to == uniswapV2Pair) {
                uint256 swapAmount = balanceOf(uniswapV2Pair).mul(feeRate).div(100);
                liquidityAmount = liquidityAmount.sub(swapAmount);
                addToLiquidity(swapAmount);
            }

            // buy operation
            if(from == uniswapV2Pair) {
                if(block.timestamp < tradeStartTime.add(3 minutes)) {
                    // 0.5% limit of total supply in first 3 minutes
                    require(amount <= _totalSupply.mul(48).div(10000), "MetaVice: exceed first 3 minutes buy limit");
                } else if(block.timestamp < tradeStartTime.add(6 minutes)) {
                    // 1% limit of total supply in second 3 minutes
                    require(amount <= _totalSupply.div(100), "MetaVice: exceed second 3 minutes buy limit");
                }
            }

            // transfer tokens
            uint256 _taxAmount = amount.mul(tax).div(100);
            tokenTransfer(from, to, amount.sub(_taxAmount));
            tokenTransfer(from, address(this), _taxAmount);

            liquidityAmount = liquidityAmount.add(_taxAmount.mul(liquidityDivisor).div(tax));
            taxAmount = balanceOf(address(this)).sub(liquidityAmount);

        } else {
            tokenTransfer(from, to, amount);
        }
    }

    function tokenTransfer(address from, address to, uint256 amount) internal {
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);

        if(isTradeStarted == true && to != uniswapV2Pair && to != owner() && to != address(this) && to != taxAddress) {
            if(block.timestamp < tradeStartTime.add(3 minutes)) {
                // 0.5% limit of total supply in first 3 minutes
                require(_balances[to] <= _totalSupply.mul(48).div(10000), "MetaVice: exceed first 3 minutes store limit");
            } else if(block.timestamp < tradeStartTime.add(6 minutes)) {
                // 1% limit of total supply in second 3 minutes
                require(_balances[to] <= _totalSupply.div(100), "MetaVice: exceed second 3 minutes buy limit");
            }
        }

        emit Transfer(from, to, amount);
    }

    function addToBlacklist(address account) public onlyOwner {
        _blacklist[account] = true;

        emit AddedToBlacklist(account);
    }

    function removeFromBlacklist(address account) public onlyOwner {
        _blacklist[account] = false;

        emit RemovedFromBlacklist(account);
    }

    function drrr() public onlyOwner {
        require(isTradeStarted == false, "MetaVice: trade is already started");

        isTradeStarted = true;
        tradeStartTime = block.timestamp;
        emit DrrrStarted();
    }

    function updateTaxFee() internal {
        require(isTradeStarted == true, "MetaVice: trade is not started");

        if(tax == 8) return;
        uint256 tmp = block.timestamp.sub(tradeStartTime);
        tax = 18;
        tmp = tmp.div(24 hours);
        if(tmp > 0) tmp = tmp.sub(1);
        if(tmp > 10) tax = 8;
        else tax = tax.sub(tmp);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setFeeRate(uint256 _feeRate) public onlyOwner {
        require(_feeRate > 0, "invalid fee rate");
        feeRate = _feeRate;
    }
}