pragma solidity ^0.8.4;

contract GeneSlimeMold{
    //全てのユーザーが持つユーザー情報
    struct GeneHolder{
        string[] gene_url_list;
        address[] approval_id_list;
        address[] block_user_list;
    }
    //限られたユーザーが持つ遺伝子を解析してブロックチェーン上に登録できる権限の情報
    struct GeneMiner{
        string description;
        address[] mined_gene_list;
        bool is_available;
    }

    //限られたユーザーが持つ遺伝子を使用するイベントを発行できる権限の情報
    struct UseEventMaker{
        string description;
        uint[] use_event_list;
        address[] avilable_use_event_list;
        bool is_available;
    }

    //発行するイベントの情報
    struct UseEvent{
        address event_owner_address;
        string description;
        Offering offering;
        bool is_approved;
        bool is_blocked;
        bool is_executed;
    }

    struct Offering{
        address offring_to_address;
        uint pay_amount;
    }
    

    mapping(address => GeneHolder) public gene_holder_list; //ユーザーと遺伝子保持情報を紐づけ
    mapping(address => GeneMiner) public gene_miner_list; //ユーザーと遺伝子マイニング情報を紐づけ
    mapping(address => UseEventMaker) public use_event_maker_list; //ユーザーと遺伝子使用イベントを紐づけ
    UseEvent[] public use_event_list;
    mapping(uint => address) public use_event_id_to_owner; //遺伝子使用イベントにidを振る

    address[] empty; //空配列
    address public supervisor; //コントラクトのオーナー
    uint use_event_id = 0; //遺伝子使用イベントId

    constructor(){
        supervisor = msg.sender; //コントラクトがデプロイされたときのオーナーをスーパーバイザーとする。
    }

/*アカウント定義　gene miner*/
    function generate_gene_miner(address miner_address, string memory description) public {
        require(supervisor == msg.sender);//ひとまずはスーパーバイザーだけが遺伝子解析事業者を操作できる様にしておく。今後は多数決で決められればいいと思っている。
        gene_miner_list[miner_address].description = description;
        gene_miner_list[miner_address].is_available = true;
    }

    function invalidate_gene_miner(address miner_address) public {
        require(supervisor == msg.sender);//ひとまずはスーパーバイザーだけが遺伝子解析事業者を操作できる様にしておく。今後は多数決で決められればいいと思っている。
        gene_miner_list[miner_address].is_available = false; 
    }

/*アカウント定義 use event maker */
    function generate_use_event_maker(address use_event_maker_address, string memory description) public {
        require(supervisor == msg.sender);//ひとまずはスーパーバイザーだけが遺伝子解析事業者を操作できる様にしておく。今後は多数決で決められればいいと思っている。
        use_event_maker_list[use_event_maker_address].description = description;
        use_event_maker_list[use_event_maker_address].is_available = true;
    }

    function invalidate_use_event_maker(address use_event_maker_address) public {
        require(supervisor == msg.sender);//ひとまずはスーパーバイザーだけが遺伝子解析事業者を操作できる様にしておく。今後は多数決で決められればいいと思っている。
        use_event_maker_list[use_event_maker_address].is_available = false; 
    }

/*遺伝子使用イベント関連 */
    //use event maker がuse event を発行する。
    function generate_use_event(string memory description, Offering offering) public{
        require(use_event_maker_list[msg.sender]);//実行者がevent makerであるかを確認

        uint id = use_event_list.push(UseEvent(msg.sender, description, offering, false, false, false)); // use_event_listに定義したuse eventを入力して、その配列の番号をidとして保持
        use_event_id_to_owner[id] = msg.sender; //use eventとそのオーナーを紐づける。
        use_event_maker_list[msg.sender].use_event_list.push(id); //自分のuse_event_listにidを加える。

        gene_holder_list[offering.offering_to_address].approval_id_list.push(id);//オファーするgene holderにidを送る。

    }
    
    //use eventを承認する。
    function approve_use_event_offer(uint use_event_id) public{
        require(use_event_list[use_event_id].offering.offering_to_address == msg.sender);
        use_event_list[use_event_id].is_approved = true;
    }
        //use eventを承認する。
    function block_use_event_offer(uint use_event_id) public{
        require(use_event_list[use_event_id].offering.offering_to_address == msg.sender);
        use_event_list[use_event_id].is_blocked = true;
    }
    
    function block_use_event_offer(uint use_event_id) public{
        require(use_event_list[use_event_id].event_owner_address == msg.sender);
        use_event_list[use_event_id].is_executed = true;
    }

}