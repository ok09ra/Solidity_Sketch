pragma solidity ^0.8.4;

contract GeneSlimeMold{

    struct GeneHolder{
        address wallet_address;
        string gene_url;
        address[] awaiting_approval_list;
        address[] block_user_list;
    }

    struct GeneMiner{
        address wallet_address;
        string description;
    }

    struct UseEventMaker{
        address wallet_address;
        string description;
        address[] use_event_list;
        address[] avilable_use_event_list;

    }
    struct UseEvent{
        address event_address;
        address event_owner;
        string description;
        Offering[] offering_list;
    }

    struct Offering{
        address offring_id;
        uint pay_amount;
        bool approvement;
    }

    GeneHolder[] private gene_holder_list;
    GeneMiner[] public gene_miner_list;
    UseEventMaker[] public use_event_maker_list;
    UseEvent[] public use_event_list;

    address public supervisor;
    address public gene_miner;
    constructor(){
        supervisor = msg.sender;
        gene_miner storage = [
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        ];
    }

    function generate_gene_holder(address holder_address, string memory gene_url) public {
        require(include_address(gene_miner, msg.sender));

        gene_holder_list.push(GeneHolder(
            holder_address,
            gene_url,
            [],
            []
        ));
    }

    function generate_gene_miner(address miner_address, string memory description) public {
        require(supervisor == msg.sender);

        gene_miner_list.push(GeneMiner(
            miner_address,
            description
        ));
    }

    function generate_use_event_maker(address event_maker_address, string memory description) public {
        require(supervisor == msg.sender);

        use_event_maker_list.push(UseEventMaker(
            event_maker_address,
            description = description,
            [],
            []
        ));
    }

    function include_address(address[] memory address_array, address target_address) private pure returns(bool){
        bool is_include = false;
        for(int i = 0; i < address_array.length(); i++){
            if(address_array[i] == target_address){
                is_include == true;
                break;
            }
        }
        return is_include;
    }
}