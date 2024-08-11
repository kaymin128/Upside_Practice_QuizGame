// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz {
    struct Quiz_item {
        uint id;
        string question;
        string answer;
        uint min_bet;
        uint max_bet;
    }
    mapping(uint => Quiz_item) public quizzes; 
    uint public quizCount = 0; 
    mapping(address => uint256)[] public bets;
    uint public vault_balance;
    uint reward=0;
    string public box;
    constructor () {
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(msg.sender!=address(1), "You are not the owner");// 비허가 주소를 거부해야함
        quizzes[q.id] = q;
        quizCount++;
        bets.push();// 퀴즈를 추가했으니 베팅 배열도 추가해야함
    }

    function getAnswer(uint quizId) public returns (string memory) { 
        quizzes[quizId].answer=box;// 박스에 담긴 정답을 다시 가져옴
        return quizzes[quizId].answer;// 정답 반환
    }

    function getQuiz(uint quizId) public returns (Quiz_item memory) { 
        box=quizzes[quizId].answer;// 정답을 박스에 담아둠
        quizzes[quizId].answer="";// 정답을 지움
        return quizzes[quizId];// quizId에 따른 퀴즈 반환
    }

    function getQuizNum() public view returns (uint) { 
        return quizCount;// 퀴즈의 개수 반환
    }
    
    function betToPlay(uint quizId) public payable { 
        require(msg.value >= quizzes[quizId].min_bet, "Bet < minimum error !");// 너무 작으면 에러
        require(msg.value <= quizzes[quizId].max_bet, "Bet > maximum error !");// 너무 커도 에러
        bets[quizId-1][msg.sender] += msg.value; // 베팅 금액을 추가
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool){ 
        quizzes[quizId].answer=box;// 혹시 모르니 박스에 담긴 정답을 가져오기
        if (keccak256(abi.encodePacked(ans)) == keccak256(abi.encodePacked(quizzes[quizId].answer))) {
            //만약 정답이 맞는 경우
            reward = bets[quizId-1][msg.sender] * 2;// 리워드가 베팅액의 두배가 됨
            bets[quizId-1][msg.sender]=0;// 베팅 금액은 사라짐
            return true;
        } else {// 정답이 틀린 경우
            vault_balance+=bets[quizId-1][msg.sender];// 잔액에 베팅액이 들어감
            bets[quizId-1][msg.sender]=0;//베팅액은 사라짐
            return false;
        }
    }

    function claim() public { 
        require(vault_balance>=reward, "insufficient balance !!");// 잔액이 리워드보다 적으면 에러
        vault_balance-=reward;// 잔액에서 리워드 가져옴
        payable(msg.sender).transfer(reward);// 사용자에게 리워드 전달
    }

    receive() external payable {
        vault_balance += msg.value;// 이더를 수신하는 함수
    }
    
}

