// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract KandySale is Ownable {
    using SafeERC20 for ERC20;
    using Address for address;

    uint constant MIMdecimals = 10 ** 18;
    uint constant Kandydecimals = 10 ** 9;
    //200k $kandy Allocated for Whitelist Sale
    uint public constant MAX_SOLD = 200000 * Kandydecimals;
    //$5 Minimum per $kandy
    uint public constant PRICE = 5 * MIMdecimals / Kandydecimals ;
    // $250 minimum sale
    uint public constant MIN_PRESALE_PER_ACCOUNT = 50 * Kandydecimals;
    // $2k maximum sale
    uint public constant MAX_PRESALE_PER_ACCOUNT = 400 * Kandydecimals;
    ERC20 MIM;

    uint public sold;
    address public Kandy;
    bool canClaim;
    bool publicSale;
    bool privateSale;
    bool giveKandyBool;
    address[] founderAddr = [0x85d708fA876a806C902b7F2FCbaC79BAF5996364, 0xd5B45dfd5340DCDd641a76D6F8D299613BE04dB2, 0x46D78800AFF415749364C727dC9AD4b5EfB04Fd7, 0x5a81c6a1D1DCA8694307Aa68dEF4D4F0F79A3F29, 0x0b8Ff541E08412B7a73C1B254AbB362d966F478b];
    mapping( address => uint256 ) public invested;
    mapping( address => uint ) public dailyClaimed;
    mapping( address => bool ) public approvedBuyers;
    mapping( address => uint256) public amountPerClaim;

    constructor() {
        //MIM CONTRACT ADDRESS
        MIM = ERC20(0x130966628846BFd36ff31a822705796e8cb8C18D);
        sold = 0;
        giveKandyBool = true;
        //Founder REWARDS(5000 allocated per dev/founder)
        for( uint256 iteration_ = 0; founderAddr.length > iteration_; iteration_++ ) {
            invested[ founderAddr[ iteration_ ] ] = 5000 * Kandydecimals;
        } 
    }
    /* check if it's not a contract */
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "!EOA");
        _;
    }

    /* approving buyers into whitelist */

    function _approveBuyer( address newBuyer_ ) internal onlyOwner() returns ( bool ) {
        approvedBuyers[newBuyer_] = true;
        return approvedBuyers[newBuyer_];
    }

    function approveBuyer( address newBuyer_ ) external onlyOwner() returns ( bool ) {
        return _approveBuyer( newBuyer_ );
    }

    function approveBuyers( address[] calldata newBuyers_ ) external onlyOwner() returns ( uint256 ) {
        for( uint256 iteration_ = 0; newBuyers_.length > iteration_; iteration_++ ) {
            _approveBuyer( newBuyers_[iteration_] );
        }
        return newBuyers_.length;
    }

    /* deapproving buyers into whitelist */

    function _deapproveBuyer( address newBuyer_ ) internal onlyOwner() returns ( bool ) {
        approvedBuyers[newBuyer_] = false;
        return approvedBuyers[newBuyer_];
    }

    function deapproveBuyer( address newBuyer_ ) external onlyOwner() returns ( bool ) {
        return _deapproveBuyer(newBuyer_);
    }

    function amountBuyable(address buyer) public view returns (uint256) {
        uint256 max;
        if ( (approvedBuyers[buyer] && privateSale) || publicSale ) {
            max = MAX_PRESALE_PER_ACCOUNT;
        }
        return max - invested[buyer];
    }

    function buyKandy(uint256 amount) public onlyEOA {
        require(sold < MAX_SOLD, "sold out");
        require(sold + amount < MAX_SOLD, "not enough remaining");
        require(amount <= amountBuyable(msg.sender), "amount exceeds buyable amount");
        require(amount + invested[msg.sender] >= MIN_PRESALE_PER_ACCOUNT, "amount is not sufficient");
        MIM.safeTransferFrom( msg.sender, address(this), amount * PRICE );
        invested[msg.sender] += amount;
        sold += amount;
    }

    // set Kandy token address and activate claiming
    function setClaimingActive(address kandy) external onlyOwner() {
        Kandy = kandy;
        canClaim = true;
    }

    //Check if you are in Founder addresses
    function isFounder(address founderAddr_) public view returns ( bool ) {
        if ( founderAddr_ == founderAddr[0] || founderAddr_ == founderAddr[1] || founderAddr_ == founderAddr[2] || founderAddr_ == founderAddr[3] || founderAddr_ == founderAddr[4]) {
            return true;
        } 
        return false;
    }

    // claim Kandy allocation based on invested amounts
    function claimKandy() public onlyEOA {
        require(canClaim, "Cannot claim now");
        require(invested[msg.sender] > 0, "no claim avalaible");
        require(dailyClaimed[msg.sender] < block.timestamp, "cannot claimed now");
        if (dailyClaimed[msg.sender] == 0) {
            dailyClaimed[msg.sender] = block.timestamp;
            amountPerClaim[msg.sender] = (isFounder(msg.sender) ? invested[msg.sender] * 10 / 100 : invested[msg.sender] * 20 / 100);
        }
        
        ERC20(Kandy).transfer(msg.sender, amountPerClaim[msg.sender]);
        invested[msg.sender] -= amountPerClaim[msg.sender];
        dailyClaimed[msg.sender] += 86400;
    }

    // token withdrawal
    function withdraw(address _token) external onlyOwner() {
        uint b = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender,b);
    }

    // manual activation of public presales
    function activatePublicSale() external onlyOwner() {
        publicSale = true;
    }
    // manual deactivation of public presales
    function deactivatePublicSale() external onlyOwner() {
        publicSale = false;
    }

    // manual activation of whitelisted sales
    function activatePrivateSale() external onlyOwner() {
        privateSale = true;
    }

    // manual deactivation of whitelisted sales
    function deactivatePrivateSale() external onlyOwner() {
        privateSale = false;
    }

    function setSold(uint _soldAmount) external onlyOwner() {
        sold = _soldAmount;
    }



    // Functions added to manually be able to add in addresses that were affected by the previous presale and give them their allocated tokens they purchased
    function giveKandyStatus() public view returns ( bool ) {
        return giveKandyBool;
    }

    // Disable the giveKandy and giveKandys function permanently 
    function disableGiveKandy() external onlyOwner() {
        giveKandyBool = false;
    }

    // Give Kandy to address without purchase
    // function giveKandy(address buyer_, uint256 amount) external onlyOwner() {
    //     require(sold < MAX_SOLD, "sold out");
    //     require(sold + amount < MAX_SOLD, "not enough remaining");
    //     require(amount <= (MAX_PRESALE_PER_ACCOUNT - invested[buyer_]), "amount exceeds buyable amount");
    //     require(amount + invested[buyer_] >= MIN_PRESALE_PER_ACCOUNT, "amount is not sufficient");
    //     require(giveKandyBool, "Period to add address over");

    //     invested[buyer_] += amount;
    //     sold += amount;
    // }

    // Remove Kandy from function
    function removeKandy(address buyer_, uint256 amount) external onlyOwner() { 
        require(amount <= invested[buyer_], "removing too much");

        invested[buyer_] -= amount;
        sold -= amount;

        amountPerClaim[buyer_] = (isFounder(buyer_) ? invested[buyer_] * 10 / 100 : invested[buyer_] * 20 / 100);

    }

    // Give Kandy to addresses without purchases
    function giveKandys( address[] calldata buyers_, uint256[] calldata amounts_  ) external onlyOwner() returns ( uint256 ) {
        require(giveKandyBool, "Period to add address over");
        require(sold < MAX_SOLD, "sold out");

        for( uint256 iteration_ = 0; buyers_.length > iteration_; iteration_++ ) {
            require(sold + amounts_[iteration_] < MAX_SOLD, "not enough remaining");
            require(amounts_[iteration_] <= (MAX_PRESALE_PER_ACCOUNT - invested[buyers_[iteration_]]), "amount exceeds buyable amount");
            require(amounts_[iteration_] + invested[buyers_[iteration_]] >= MIN_PRESALE_PER_ACCOUNT, "amount is not sufficient");

            invested[buyers_[iteration_]] += amounts_[iteration_];
            sold += amounts_[iteration_];
        }
        return buyers_.length;
    }

}
