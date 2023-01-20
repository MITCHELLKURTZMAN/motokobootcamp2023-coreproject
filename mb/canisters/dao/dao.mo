// The DAO is controlling a webpage and is able to modify the text on that page through proposals.

// The DAO can create proposals. Each user is able to vote on proposals if he has at least 1 Motoko Bootcamp (MB)token.

// The voting power of any member is equal to the number of MB they hold (at the moment they cast their vote).

// A proposal will automatically be passed if the cumulated voting power of all members that voted for it is equals or above 100.

// A proposal will automatically be rejected if the cumulated voting power of all members that voted against it is equals or above 100.

// Here is a few functions that you'll need to implement in your canister

// submit_proposal
// get_proposal
// get_all_proposals
// vote

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import U "utility";
import Option "mo:base/Option";
import Time "mo:base/Time";

actor Dao {

    //list of dao members

    //data type aliases
    type List<T> = List.List<T>;

    type Proposal = {
        id : Nat;
        pageText : Text;
        vote : Int;
        status : Text
    };

    public type Neuron = {
        id : Nat;
        principalId : Text;
        created : Int;
        stake : Nat;
        stakeReleaseDate : Int;
        state : NeuronState;
        vote : Int;
        proposalId : Nat
    };
    public type NeuronState = {
        #locked;
        #dissolving;
        #dissolved
    };

    public type VoteOptions = {
        #yes;
        #no
    };

    stable var members : List.List<Text> = List.nil<Text>();
    stable var principalIdEntries : [(Text, Text)] = [];
    stable var idEntries : [(Text, Text)] = [];
    stable var pageTextEntries : [(Text, Text)] = [];
    stable var voteEntries : [(Text, Int)] = [];
    stable var statusEntries : [(Text, Text)] = [];
    stable var proposalId = 0;
    stable var pageText = "Hello World";

    system func preupgrade() {
        principalIdEntries := Iter.toArray(principalIdHashMap.entries());
        idEntries := Iter.toArray(idHashMap.entries());
        pageTextEntries := Iter.toArray(pageTextHashMap.entries());
        voteEntries := Iter.toArray(voteHashMap.entries());
        statusEntries := Iter.toArray(statusHashMap.entries())
    };

    system func postupgrade() {

        principalIdEntries := [];
        idEntries := [];
        pageTextEntries := [];
        voteEntries := [];
        statusEntries := []
    };

    //error messages
    let Unauthorized = "Unauthorized";

    //utils
    func isEq(x : Text, y : Text) : Bool { x == y };
    var maxHashmapSize = 1000000;
    var hashMap = HashMap.HashMap<Text, [Text]>(maxHashmapSize, isEq, Text.hash);

    //dao section

    var principalIdHashMap = HashMap.fromIter<Text, Text>(principalIdEntries.vals(), maxHashmapSize, isEq, Text.hash);
    var idHashMap = HashMap.fromIter<Text, Text>(idEntries.vals(), maxHashmapSize, isEq, Text.hash);
    var pageTextHashMap = HashMap.fromIter<Text, Text>(pageTextEntries.vals(), maxHashmapSize, isEq, Text.hash);
    var voteHashMap = HashMap.fromIter<Text, Int>(voteEntries.vals(), maxHashmapSize, isEq, Text.hash);
    var statusHashMap = HashMap.fromIter<Text, Text>(statusEntries.vals(), maxHashmapSize, isEq, Text.hash);

    //proposal section
    var userProposedHashMap = HashMap.HashMap<Text, Int>(maxHashmapSize, isEq, Text.hash);
    var proposalHashMap = HashMap.HashMap<Text, Proposal>(maxHashmapSize, isEq, Text.hash);
    var proposalVotesByPrincipalHashMap = HashMap.HashMap<Text, [Text]>(maxHashmapSize, isEq, Text.hash);

    //neuron section
    var neuronHashMap = HashMap.HashMap<Text, Neuron>(maxHashmapSize, isEq, Text.hash);
    var neuronOwnerHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash);
    var neuronStakeHashMap = HashMap.HashMap<Text, Nat>(maxHashmapSize, isEq, Text.hash);
    var neuronStakeReleaseDateHashMap = HashMap.HashMap<Text, Nat>(maxHashmapSize, isEq, Text.hash);
    var neuronStatusHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash);
    var neuronVoteHashMap = HashMap.HashMap<Text, Int>(maxHashmapSize, isEq, Text.hash);

    public query func getProposalId() : async Text {
        return Nat.toText(proposalId)
    };

    public query func getPageText() : async Text {
        return pageText
    };

    public shared func adminReset() {
        proposalId := 0;
        proposalHashMap := HashMap.HashMap<Text, Proposal>(maxHashmapSize, isEq, Text.hash)
    };

    private func buildProposal(id : Nat) : Proposal {

        let proposal = {
            id = id;
            pageText = U.safeGet(pageTextHashMap, Nat.toText(id), "");
            vote = U.safeGet(voteHashMap, Nat.toText(id), 0);
            status = U.safeGet(statusHashMap, Nat.toText(id), "")
        };

        proposal
    };

    public type Account__1 = { owner : Principal; subaccount : ?Subaccount };
    public type Subaccount = [Nat8];
    public type Balance__1 = Nat;

    let MBTOKENACTOR = actor ("db3eq-6iaaa-aaaah-abz6a-cai") : actor {

        icrc1_balance_of : shared query Account__1 -> async Balance__1;

        icrc1_name : shared query () -> async Text;

        icrc1_symbol : shared query () -> async Text;

    };

    let CertifiedDAO = actor ("txssk-maaaa-aaaaa-aaanq-cai") : actor {

        update_dao_text : shared query Text -> async ();

    };

    public shared func update_dao_text() : async () {
        await CertifiedDAO.update_dao_text(pageText)
    };

    public shared func getMBTokenBalance(owner : Text) : async Nat {
        let balance = await MBTOKENACTOR.icrc1_balance_of({
            owner = Principal.fromText(owner);
            subaccount = null
        });
        balance
    };

    public shared ({ caller }) func submit_proposal(text : Text) : async Result.Result<(), Text> {

        let principalId = Principal.toText(caller);

        //todo: uncomment this
        // let tokenBalance = await getMBTokenBalance(principalId);
        // if (tokenBalance == 0) {
        //     return #err("You need to have MB tokens to submit a proposal")
        // };

        proposalId := proposalId + 1;

        let proposal = {
            id = proposalId;
            pageText = text;
            vote = 0;
            status = "Pending"
        };

        principalIdHashMap.put(principalId, Nat.toText(proposalId));
        pageTextHashMap.put(Nat.toText(proposalId), text);
        voteHashMap.put(Nat.toText(proposalId), 0);
        statusHashMap.put(Nat.toText(proposalId), "Pending"); //Pending, Passed, Rejected
        proposalHashMap.put(Nat.toText(proposalId), proposal);

        #ok()
    };

    public shared ({ caller }) func get_proposal(id : Nat) : async Result.Result<Proposal, Text> {

        let proposal = U.safeGet(proposalHashMap, Nat.toText(id), { id = 0; pageText = ""; vote = 0; status = "" });

        #ok(proposal)
    };

    public shared ({ caller }) func get_all_proposals() : async Result.Result<[Proposal], Text> {

        let proposalList = proposalHashMap.vals();
        let proposalArray = Iter.toArray(proposalList);

        #ok(proposalArray);

    };

    //whoami canister
    public shared query ({ caller }) func whoAmI() : async Text {
        let principalId = Principal.toText(caller);
        principalId
    };

    //todo think this needs to be private todo to prevent setting your own vote power
    public shared ({ caller }) func vote(id : Nat, vote : VoteOptions, principalIdArg : Text, votePower : Nat) : async Result.Result<Proposal, Text> {
        type Buffer = Buffer.Buffer<Text>;
        //todo scale voting power correctly for token balance
        //temp return for voting power
        let canister = await whoAmI();
        let principalId = if (canister == Principal.toText(caller)) {
            principalIdArg
        } else {
            Principal.toText(caller)
        };
        // let tokenBalance = await getMBTokenBalance(principalId);
        // if (tokenBalance == 0) {
        //     return #err("You need to have MB tokens to vote on a proposal")
        // };
        let tokenBalance = 100;

        let votingPower = if (vote == #yes) { 1 * votePower } else {
            1 * votePower
        };

        let proposal = buildProposal(id);

        //get votes by principal to update votes array
        var votesByPrincipal = U.safeGet(proposalVotesByPrincipalHashMap, principalId, []);
        //buffer
        var buffer : Buffer = Buffer.fromArray(votesByPrincipal);
        buffer.add(Nat.toText(id));
        Debug.print("added to buffer: " # Nat.toText(id));

        votesByPrincipal := Iter.toArray(buffer.vals());

        proposalVotesByPrincipalHashMap.put(principalId, votesByPrincipal);

        if (proposal.status == "Pending") {

            let currentVote = proposal.vote;

            let newVote = currentVote + votingPower;

            voteHashMap.put(Nat.toText(id), newVote);

            if (newVote >= 100) {
                statusHashMap.put(Nat.toText(id), "Passed");
                pageText := proposal.pageText;
                ignore update_dao_text()
            };

            if (newVote <= -100) {
                statusHashMap.put(Nat.toText(id), "Rejected")
            };

            return #ok(buildProposal(id));

        } else {
            return #err("Proposal is " # proposal.status)
        };

    };

    // advanced functions
    // If you want to graduate with honors you'll have to complete those additional requirements:

    // Users are able to lock their MB tokens to create neurons by specifying an amount and a dissolve delay.

    // Neurons can be in 3 different states:

    // Locked: the neuron is locked with a set dissolve delay and the user needs to switch it to dissolving to access their MB.
    // Dissolving: the neuron's dissolve delay decreases over time until it reaches 0 and then the neuron is dissolved and the user can access their ICP.
    // Dissolved: the neuron's dissolve delay is 0 and the user can access their ICP. The dissolve delay can be increased after the neuron is created but can only be decreased over time while the neuron is in dissolving state. Also, neurons can only vote if their dissolve delay is more than 6 months. Additionally, neurons have an age which represents the time passed since it was created or last stopped dissolving.
    // Voting power of a neuron is counted as followed: AMOUNT MB TOKENS * DISSOLVE DELAY BONUS * AGE BONUS where:

    // Dissolve delay bonus: The bonuses scale linearly, from 6 months which grants a 1.06x voting power bonus, to 8 years which grants a 2x voting power bonus
    // Age bonus: the maximum bonus is attained for 4 years and grants a 1.25x bonus, multiplicative with any other bonuses. The bonuses for durations between 0 seconds and 4 years scale linearly between.
    // Proposals are able to modify the following parameters:

    // The minimum of MB token necessary to vote (by default - 1).
    // The amount of voting power necesary for a proposal to pass (by default - 100).
    // An option to enable quadratic voting, which makes voting power equal to the square root of their MB token balance.

    // The canister is blackholed.

    // Here is a few functions that you'll need to implement in your canister

    // ✅modify_parameters
    // quadratic_voting
    // createNeuron
    // dissolveNeuron

    //modify_parameters
    private stable var minimumAmountOfToken = 1;
    private stable var acceptanceThreshold = 100;

    private func modify_parameters(minimum_token : Nat, threshold : Nat) : () {
        minimumAmountOfToken := minimum_token;
        acceptanceThreshold := threshold
    };

    //quadratic_voting
    //returns number of votes for proposal by principal
    func hasUserVoted(id : Nat, principalId : Text) : Nat {
        let proposalVotes = proposalVotesByPrincipalHashMap.get(principalId);
        switch proposalVotes {
            case (null) { 0 };
            case (?votes) {
                //loop array and count the instances of the proposal id
                var count = 0;
                for (vote in votes.vals()) {
                    if (vote == Nat.toText(id)) {
                        count := count + 1
                    }
                };
                count
            }
        }

    };
    //if a user has voted, it will cost them 'vote + 1'^2 tokens to vote again on the same proposal
    //This is the first understanding I had of what quadratic voting was, but the guide calls for a different implementation. I'll leave this here for now as altQuadratic_voting
    // The idea in this case would be spending exponentially more tokens to vote on the same proposal, but the cost would be the same for each vote
    // This would require collecting tokens, rather than just accounting, so I see why it's not the preferred implementation
    // public shared ({ caller }) func altQuadratic_voting(voteOptions : VoteOptions, proposal : Nat) : async Result.Result<Text, Text> {
    //     var votingCost = 1;
    //     //todo neuron or token check
    //     let principalId = Principal.toText(caller);
    //     //let tokenBalance = await getMBTokenBalance(principalId);
    //     let tokenBalance = 100000000;
    //     if (tokenBalance < minimumAmountOfToken) {
    //         return #err("You need to have MB tokens to vote on a proposal")
    //     };

    //     let hasVoted = hasUserVoted(proposal, principalId);

    //     if (hasVoted == 0) {
    //         //first vote
    //         votingCost := 1
    //     } else {
    //         //second vote and beyond
    //         votingCost := (hasVoted + 1) * (hasVoted + 1)
    //     };

    //     if (tokenBalance < votingCost) {
    //         return #err("You need to have " # Nat.toText(votingCost) # " MB tokens to vote on a proposal")
    //     };

    //     let quadraticVote = await vote(proposal, voteOptions, principalId, votePower);

    //     switch (vote(proposal, voteOptions, principalId, votePower)) {
    //         case (proposal) {
    //             #ok("Voted qudratically, your vote cost was " # Nat.toText(votingCost) # " MB tokens")
    //         };
    //         case (_) { #err "Error voting" }
    //     }

    // };

    // let userPower = Int.abs(Float.toInt(Float.sqrt(Float.fromInt(userBalance) / 100000000)));
    public shared ({ caller }) func quadratic_voting(voteOptions : VoteOptions, proposal : Nat) : async Result.Result<Text, Text> {
        let principalId = Principal.toText(caller);
        let tokenBalance = 1000; //todo: await getMBTokenBalance(principalId);
        if (tokenBalance < minimumAmountOfToken / 100000000) {
            return #err("You need to have MB tokens to vote on a proposal " # "caller is " # principalId # " and balance is " # Nat.toText(tokenBalance) # " the sqrt of " # Nat.toText(tokenBalance) # " and the minimum is " # Nat.toText(minimumAmountOfToken))
        };
        let votePower = Int.abs(Float.toInt(Float.sqrt(Float.fromInt(tokenBalance)))); // todo: if the user wants more voting power they buy more tokens. add /100,000 to account for amount of tokens you can purcase at a time
        let myVote = await vote(proposal, voteOptions, principalId, votePower);
        switch (vote) {
            case (proposal) {
                #ok("Voted qudratically, your vote power was " # Nat.toText(votePower) # " MB tokens")
            };
            case (_) { #err "Error voting" }
        }
    };

    //get votes by principal
    public shared ({ caller }) func get_votes_by_principal() : async Result.Result<[Text], Text> {
        let principalId = Principal.toText(caller);
        let votes = U.safeGet(proposalVotesByPrincipalHashMap, principalId, []);
        #ok(votes)
    };

    //neuron functions
    public shared ({ caller }) func createNeuron(lockTime : Int) : async Result.Result<Neuron, Text> {
        let time = Time.now();
        let six_months = 15778800000000000;
        if (lockTime > 16 * six_months or lockTime < six_months) {
            return #err("Dissolve delay can not be higher than 8 years or lower than 6 months!")
        };
        let principalId = Principal.toText(caller);
        let tokenBalance = await getMBTokenBalance(principalId);
        if (tokenBalance < minimumAmountOfToken) {
            return #err("You need to have MB tokens to create a neuron")
        };
        let neuronId = neuronHashMap.size() + 1;
        let neuron = {
            created = time;
            id = neuronId;
            principalId = principalId;
            proposalId = 0;
            stake = tokenBalance;
            stakeReleaseDate = time + lockTime;
            state = #locked;
            vote = 0;

        };
        neuronHashMap.put(Nat.toText(neuronId), neuron);
        #ok(neuron)
    };

}

//todo get votes by principal not working which causes quadratic voting to not work
//todo neuron functions, state, dissolve, vote
