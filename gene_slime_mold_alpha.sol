pragma solidity ^0.8.4;

contract GeneSlimeMold{
    //全てのユーザーが持つユーザー情報
    struct GeneHolder{
        uint[] gene_mining_data_id_list;
        uint[] approval_id_list;
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
        address offer_to_address;
        uint pay_amount;
        bool is_approved;
        bool is_blocked;
        bool is_executed;
    }
    
    struct GeneMiningData{
        string url;
        string description;
        address gene_holder_address;
        address miner_address;
        bool is_accepted_by_holder;
        bool is_blocked_by_holder;
    }

    mapping(address => GeneHolder) private gene_holder_list; //ユーザーと遺伝子保持情報を紐づけ
    mapping(address => GeneMiner) private gene_miner_list; //ユーザーと遺伝子マイニング情報を紐づけ
    mapping(address => UseEventMaker) private use_event_maker_list; //ユーザーと遺伝子使用イベントを紐づけ
    mapping(uint => address) public use_event_id_to_owner; //遺伝子使用イベントにidを振る

    UseEvent[] public use_event_list;
    GeneMiningData[] public gene_mining_data_list;

    address[] empty; //空配列
    address public supervisor; //コントラクトのオーナー

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

/*遺伝子使用イベント定義関連 */
    //use event maker がuse event を発行する。
    function generate_use_event(string memory description, address offer_to_address, uint payment) public {
        require(use_event_maker_list[msg.sender].is_available);//実行者がevent makerであるかを確認
        uint id = use_event_list.length;
        
        use_event_list.push(UseEvent(msg.sender, description, offer_to_address, payment, false, false, false)); // use_event_listに定義したuse eventを入力して、その配列の番号をidとして保持
        use_event_id_to_owner[id] = msg.sender; //use eventとそのオーナーを紐づける。
        use_event_maker_list[msg.sender].use_event_list.push(id); //自分のuse_event_listにidを加える。

        gene_holder_list[offer_to_address].approval_id_list.push(id);//オファーするgene holderにidを送る。
    }
    
    //use eventを承認する。
    function approve_use_event_offer(uint use_event_id) public{
        require(use_event_list[use_event_id].offer_to_address == msg.sender);
        use_event_list[use_event_id].is_approved = true;
        use_event_list[use_event_id].is_blocked = false;
    }

    //use eventを棄却する。
    function block_use_event_offer(uint use_event_id) public{
        require(use_event_list[use_event_id].offer_to_address == msg.sender);
        use_event_list[use_event_id].is_blocked = true;
        use_event_list[use_event_id].is_approved = false;
    }

/*遺伝情報の定義情報*/
    //解析情報を追加する
    function register_mining_gene(address gene_holder_address, string memory gene_url, string memory description) public {
        require(gene_miner_list[msg.sender].is_available);
        uint id = gene_mining_data_list.length;
        gene_mining_data_list.push(GeneMiningData(gene_url, description, gene_holder_address, msg.sender, false, false));
        gene_holder_list[gene_holder_address].gene_mining_data_id_list.push(id);
    }
    
    //本人がその解析情報を承認する。
    function accept_mining_gene(uint gene_mining_data_id) public {
        require(gene_mining_data_list[gene_mining_data_id].gene_holder_address == msg.sender);
        gene_mining_data_list[gene_mining_data_id].is_blocked_by_holder = false;
        gene_mining_data_list[gene_mining_data_id].is_accepted_by_holder = true;
    }

    //本人がその解析情報を棄却する。
    function blocked_mining_gene(uint gene_mining_data_id) public {
        require(gene_mining_data_list[gene_mining_data_id].gene_holder_address == msg.sender);
        gene_mining_data_list[gene_mining_data_id].is_accepted_by_holder = false;
        gene_mining_data_list[gene_mining_data_id].is_blocked_by_holder = true;
    }

/*情報表示関連*/
    //自分の遺伝子解析情報を取得する。
    function request_own_gene_mining_data() public returns(GeneMiningData[]){
        uint[] memory gene_mining_data_id_list; 
        GeneMiningData[] memory own_gene_mining_data_list
        gene_mining_data_id_list = gene_holder_list[msg.sender].gene_mining_data_id_list;        
        
        for(uint i = 0; i < gene_mining_data_id_list.length; i++){
            own_gene_mining_data_list[i] = gene_mining_data_list[gene_mining_data_id_list[i]];
        }

        return own_gene_mining_data_list;
    }
}