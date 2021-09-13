// SPDX-License-Identifier: GPL-3.0;
pragma solidity ^0.8.0;

contract Dao {
    // Global Variables
  
    struct ProjectProposal {
        address projectOwner;
        // address projectWallet;
        string projectName;
        string projectDescription;
        uint createdAt;
        uint yesVotes;
        uint noVotes;
        ProposalVotingState proposalVotingState;
        mapping(address => Vote) votesByMember;
        mapping(address => uint) contributor;
        address[] contributors;
    }
    enum ProposalVotingState{
            REJECTED,
            ONGOING,
            APPROVED
    }
    uint projectId;
    ProjectProposal[] ProjectProposals;
    mapping(uint => ProjectProposal) public project_Proposal;
    // DAO Members will be added by admin
    struct DaoMember{
        address member;
        uint votingPower;
        bool exists;
    }
    mapping(address => DaoMember) public DaoMembers;
    DaoMember[] allDaoMembers;
    // Votes
    // require that only approved proposal
    enum Vote { Null, No, Yes }
    // enum Payment { Start, Ongoing, Closed } // platform
    

    
    modifier onlyDaoMember(){
        require(DaoMembers[msg.sender].votingPower > 0, "not a member");
        _;
    }
    function addDaoMember(address _member, uint _votingPower) public returns(bool){
        DaoMember storage _daoMember = DaoMembers[_member];
        _daoMember.member =_member;
         _daoMember.votingPower = _votingPower;
         _daoMember.exists =  true;
        allDaoMembers.push(_daoMember);
       
    }
    // function removeDaoMember(address _member) public onlyAdmin{
    //     delete DaoMembers[_member];
    // }
    // PROPOSAL FUNCTIONS
    function SubmitProjectProposal(address _projectOwner, string memory _projectName,string memory _projectDescription) public {
        ProjectProposal storage project =  project_Proposal[projectId];
        project.projectOwner = _projectOwner;
        project.projectName = _projectName;
        project.projectDescription = _projectDescription;
        project.proposalVotingState = ProposalVotingState.ONGOING;
        projectId++;
        
    }
    function vote(uint _projectId, uint8 _vote) public onlyDaoMember {
        require (_projectId < projectId);
        ProjectProposal storage project =  project_Proposal[_projectId];
        require (project.proposalVotingState == ProposalVotingState.ONGOING);
       
        require (project.votesByMember[msg.sender] == Vote.Null, 'Already voted');
        require (_vote < 3,'Invalid Selection');
        Vote vote_ = Vote(_vote);
        DaoMember memory _daoMember = DaoMembers[msg.sender];
        if (vote_ == Vote.Yes) {
            project.yesVotes += _daoMember.votingPower;
            project.votesByMember[msg.sender] = Vote.Yes;
        }
        if (vote_ == Vote.No) {
            project.noVotes += _daoMember.votingPower;
            project.votesByMember[msg.sender] = Vote.No;
        }
        
       
    }
    function countvote(uint _projectId)public view returns(uint){
        ProjectProposal storage project =  project_Proposal[_projectId];
        return project.yesVotes;
    }
}