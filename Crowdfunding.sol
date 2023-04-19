// SPDX-License-Identifier: MIT

pragma solidity >=0.8.18;

contract Found {
    enum ProjectState {
        Opened,
        Closed
    }

    struct Project {
        string id;
        string name;
        string description;
        address payable author;
        ProjectState state;
        uint256 funds;
        uint256 projectGoal;
    }

    struct Contribution {
        address contributor;
        uint value;
    }


    Project[] public projects;
    mapping(string => Contribution[]) public contributions;

    event ProjectCreated(
        string projectId,
        string name,
        string description,
        uint256 projectGoal
    );

    event ProjectFunded(string projectId, uint256 value);

    event ProjectStateChanged(string id, ProjectState state);

    modifier isAuthor(uint256 projectIndex) {
        require(
            projects[projectIndex].author == msg.sender,
            "You need to be the project author"
        );
        _;
    }

    modifier isNotAuthor(uint256 projectIndex) {
        require(
            projects[projectIndex].author != msg.sender,
            "As author you can not fund your own project"
        );
        _;
    }

    function createProject (
        string calldata id,
        string calldata name,
        string calldata description,
        uint projectGoal
    ) public {
        require(projectGoal > 0, "fund goal must be grather than 0");
        Project memory project = Project(id, name, description, payable(msg.sender), ProjectState.Opened, 0, projectGoal);
        projects.push(project);
        emit ProjectCreated(id, name, description, projectGoal);
    }

    function fundProject(uint256 projectIndex) public payable isNotAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != ProjectState.Closed, "The project can not receive funds because it is closed.");
        require(msg.value > 0, "Fund value must be grather than 0.");
        project.author.transfer(msg.value);
        project.funds += msg.value;
        projects[projectIndex] = project;

        contributions[project.id].push(Contribution(msg.sender, msg.value));

        emit ProjectFunded(project.id, msg.value);
    }

    function changeProjectState(ProjectState newState, uint256 projectIndex)
        public
        isAuthor(projectIndex)
    {
        Project memory project = projects[projectIndex];
        require(project.state != newState, "New state must be different");
        project.state = newState;
        projects[projectIndex] = project;
        emit ProjectStateChanged(project.id, newState);
    }
}
