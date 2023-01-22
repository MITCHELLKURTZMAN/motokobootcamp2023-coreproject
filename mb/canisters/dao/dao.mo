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
import Blob "mo:base/Blob";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import U "utility";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Nat8 "mo:base/Nat8";

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
        ownerPrincipal : Text;
        created : Int;
        stake : Nat;
        disolveDelay : Int;
        state : NeuronState;
        subAccount : Subaccount
    };
    public type NeuronState = {
        #locked;
        #dissolving;
        #dissolved
    };

    public type PublicChat = {
        chatId : Nat;
        ownerPrincipal : Text;
        created : Int;
        message : Text
    };

    stable var members : List.List<Text> = List.nil<Text>();
    stable var principalIdEntries : [(Text, Text)] = [];
    stable var idEntries : [(Text, Text)] = [];
    stable var pageTextEntries : [(Text, Text)] = [];
    stable var voteEntries : [(Text, Int)] = [];
    stable var statusEntries : [(Text, Text)] = [];
    stable var proposalId = 0;
    stable var pageText = "Hello World";
    private stable var neuronId = 0;

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

    public shared query ({ caller }) func getPrincipalId() : async Text {
        let principalId = Principal.toText(caller);
        return principalId
    };

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
    var neuronIdHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash); //id to principal
    var neuronOwnerPrincipalHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash); //principal to id
    var neuronCreatedHashMap = HashMap.HashMap<Text, Int>(maxHashmapSize, isEq, Text.hash);
    var neuronStakeHashMap = HashMap.HashMap<Text, Nat>(maxHashmapSize, isEq, Text.hash);
    var neuronDisolveDelayHashMap = HashMap.HashMap<Text, Int>(maxHashmapSize, isEq, Text.hash);
    var neuronStateHashMap = HashMap.HashMap<Text, NeuronState>(maxHashmapSize, isEq, Text.hash);
    var neuronSubAccountHashMap = HashMap.HashMap<Text, Subaccount>(maxHashmapSize, isEq, Text.hash);
    var neuronIsDisolvedDateHashMap = HashMap.HashMap<Text, Int>(maxHashmapSize, isEq, Text.hash);

    //chat section
    var chatIdHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash);
    var chatOwnerPrincipalHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash);
    var chatCreatedHashMap = HashMap.HashMap<Text, Int>(maxHashmapSize, isEq, Text.hash);
    var chatMessageHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash);

    public shared query func isblackhole() : async Text {

        return "to see blackhole canister run:  dfx canister info ushh5-caaaa-aaaak-ad72a-cai --network ic "

    };

    public query func getProposalId() : async Text {
        return Nat.toText(proposalId)
    };

    public query func getPageText() : async Text {
        return pageText
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

    public type ICRC_1_account = { owner : Principal; subaccount : ?[Nat8] };

    public type TimeError = {
        #TooOld;
        #CreatedInFuture : { ledger_time : Nat64 }
    };

    public type TransferError = TimeError or {
        #BadFee : { expected_fee : Nat };
        #BadBurn : { min_burn_amount : Nat };
        #InsufficientFunds : { balance : Nat };
        #Duplicate : { duplicate_of : Nat };
        #TemporarilyUnavailable;
        #GenericError : { error_code : Nat; message : Text }
    };
    let MBTOKENACTOR = actor ("db3eq-6iaaa-aaaah-abz6a-cai") : actor {
        icrc1_balance_of : (account : ICRC_1_account) -> async Nat;
        icrc1_transfer : (args : TransferArgs) -> async Result.Result<Nat, TransferError>;
        icrc1_fee : () -> async Nat;
        icrc1_name : shared query () -> async Text;
        icrc1_symbol : shared query () -> async Text
    };

    public type TransferArgs = {
        from_subaccount : ?[Nat8];
        to : ICRC_1_account;
        amount : Nat;
        fee : ?Nat;
        memo : ?Blob;

        created_at_time : ?Nat64
    };

    let CertifiedDAO = actor ("ushh5-caaaa-aaaak-ad72a-cai") : actor {

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
        // let balance = 100000000 * 100;
        return balance
    };

    public shared func getNeuronMBTokenBalance(owner : Text, subaccount : Subaccount) : async Nat {
        let balance = await MBTOKENACTOR.icrc1_balance_of({
            owner = Principal.fromText(owner);
            subaccount = ?subaccount
        });
        // let balance = 100000000 * 100;
        return balance
    };

    public shared ({ caller }) func submit_proposal(text : Text) : async Result.Result<(), Text> {

        let principalId = Principal.toText(caller);

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

    public shared query ({ caller }) func get_proposal(id : Nat) : async Result.Result<Proposal, Text> {

        let proposal = U.safeGet(proposalHashMap, Nat.toText(id), { id = 0; pageText = ""; vote = 0; status = "" });

        #ok(proposal)
    };

    public shared query ({ caller }) func get_all_proposals() : async Result.Result<[Proposal], Text> {

        let proposalList = proposalHashMap.vals();
        var proposalBuffer = Buffer.Buffer<Proposal>(0);

        //loop through build proposal func
        for (proposal in proposalList) {
            proposalBuffer.add(buildProposal(proposal.id))

        };

        let proposalarray = proposalBuffer.toArray();

        #ok(proposalarray)
    };

    //whoami canister
    public shared query ({ caller }) func whoAmI() : async Text {
        let principalId = Principal.toText(caller);
        principalId
    };

    public shared query func getVotePercent(id : Nat) : async Int {
        let proposal = U.safeGet(voteHashMap, Nat.toText(id), 0);
        let vote = proposal;

        vote
    };

    //todo think this needs to be private todo to prevent setting your own vote power
    public shared ({ caller }) func vote(id : Nat, vote : Bool, principalIdArg : Text, votePower : Nat) : async Result.Result<Proposal, Text> {
        type Buffer = Buffer.Buffer<Text>;

        let canister = await whoAmI();
        let principalId = if (canister == Principal.toText(caller)) {
            principalIdArg
        } else {
            Principal.toText(caller)
        };

        //check if user has a neuron
        if (principalId == "2vxsx-fae") {
            return #err("You need to log in and have MB tokens to vote on a proposal")
        };
        let tokenBalance = await getMBTokenBalance(principalId);
        if (tokenBalance == 0) {
            return #err("You need to have MB tokens to vote on a proposal")
        };

        let votingPower : Int = if (vote == true) { 1 * votePower } else {
            -1 * votePower
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
            proposalHashMap.put(Nat.toText(id), { id = id; pageText = proposal.pageText; vote = newVote; status = proposal.status });
            Debug.print("new vote: " # Int.toText(newVote));

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
    // ✅quadratic_voting
    // ✅createNeuron
    // ✅dissolveNeuron

    //modify_parameters
    private stable var minimumAmountOfToken = 1; // 1 token == 100,000,000 therefore we need to divide all returns by 100,000,000
    private stable var acceptanceThreshold = 100;

    //todo threshhold proposal
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

    func isNeuron(principalId : Principal) : Text {
        let neuron = neuronIdHashMap.get(Principal.toText(principalId));
        switch neuron {
            case (null) { "0" };
            case (?result) { result }
        }
    };

    // let userPower = Int.abs(Float.toInt(Float.sqrt(Float.fromInt(userBalance) / 100000000)));
    public shared ({ caller }) func quadratic_voting(voteOptions : Bool, proposal : Nat) : async Result.Result<Text, Text> {
        //make specific case for neuron voting and power adjustments
        let principalId = Principal.toText(caller);
        let doesUserHaveNeuron = isNeuron(caller);

        if (principalId == ("2vxsx-fae")) {
            return #err("you must log in and have MB tokens to vote")
        };
        let tokenBalance = await getMBTokenBalance(principalId);
        if (tokenBalance < minimumAmountOfToken / 100000000) {
            return #err("You need to have MB tokens to vote on a proposal " # "caller is " # principalId # " and balance is " # Nat.toText(tokenBalance) # " the sqrt of " # Nat.toText(tokenBalance) # " and the minimum is " # Nat.toText(minimumAmountOfToken))
        };
        var votePower = Int.abs(Float.toInt(Float.sqrt(Float.fromInt(tokenBalance))));
        //if user has neuron, add neuron power to vote power
        if (doesUserHaveNeuron != "0") {
            let neuron = neuronIdHashMap.get(doesUserHaveNeuron);
            switch neuron {
                case (null) {};
                case (?neuron) {
                    let neuronPower = getNeuronVotePower(doesUserHaveNeuron);
                    votePower := votePower + Int.abs(neuronPower)
                }
            }
        };

        let myVote = await vote(proposal, voteOptions, principalId, votePower);
        switch (vote) {
            case (proposal) {
                #ok("Voted qudratically, your vote power was " # Nat.toText(votePower) # " MB tokens")
            };
            case (_) { #err "Error voting" }
        }

    };

    public shared ({ caller }) func neuronVote(voteOptions : Bool, proposal : Nat) : async Result.Result<Text, Text> {
        let principalId = Principal.toText(caller);
        let neuron = buildNeuron(principalId);
        if (neuron.id == 0) {
            return #err("You need to have a neuron to vote")
        };

        let neuronPower = getNeuronVotePower(Nat.toText(neuron.id));
        let myVote = await vote(proposal, voteOptions, principalId, Int.abs(neuronPower));

        switch (vote) {
            case (proposal) {
                #ok("Voted qudratically, your vote power was " # Nat.toText(Int.abs(neuronPower)) # " MB tokens")
            };
            case (_) { #err "Error voting" }
        }

    };

    //get votes by principal
    public shared query ({ caller }) func get_votes_by_principal() : async Result.Result<[Text], Text> {
        let principalId = Principal.toText(caller);
        let votes = U.safeGet(proposalVotesByPrincipalHashMap, principalId, []);
        #ok(votes)
    };

    private func getNewNeuronID(principalId : Text) : Nat {
        neuronId := neuronId + 1;
        return neuronId

    };

    private func buildNeuron(principalId : Text) : Neuron {
        let neuronId = U.safeGet(neuronIdHashMap, principalId, "0");
        let created = U.safeGet(neuronCreatedHashMap, neuronId, 0);
        let stake = U.safeGet(neuronStakeHashMap, neuronId, 0);
        let disolveDelay = U.safeGet(neuronDisolveDelayHashMap, neuronId, 0);
        let state = U.safeGet(neuronStateHashMap, neuronId, #locked);
        let subaccount = U.safeGet(neuronSubAccountHashMap, neuronId, [0 : Nat8]);
        {
            id = U.textToNat(neuronId);
            ownerPrincipal = principalId;
            created = created;
            stake = stake;
            disolveDelay = disolveDelay;
            state = state;
            subAccount = subaccount
        };

    };

    public shared query ({ caller }) func getNeuron() : async Result.Result<Neuron, Text> {
        let principalId = Principal.toText(caller);
        let neuron = buildNeuron(principalId);
        #ok(neuron)
    };

    public shared query ({ caller }) func get_subaccount_to_lock_tokens() : async [Nat8] {
        get_subaccount_by_principal(caller)
    };

    private func get_subaccount_by_principal(p : Principal) : [Nat8] {
        let buffer = Buffer.Buffer<Nat8>(0);
        for (nat8 in Blob.toArray(Text.encodeUtf8(Principal.toText(p))).vals()) {
            if (buffer.size() < 32) {
                buffer.add(nat8)
            }
        };
        buffer.toArray()
    };

    //neuron functions
    public shared ({ caller }) func createNeuron(lockTime : Int, stake : Int) : async Result.Result<Neuron, Text> {
        let time = Time.now();
        let six_months = 15778800000000000;
        let lockTimeInMonths = lockTime * six_months / 6;
        if (lockTimeInMonths > 16 * six_months or lockTimeInMonths < six_months) {
            return #err("Dissolve delay can not be higher than 8 years or lower than 6 months!")
        };

        let principalId = Principal.toText(caller);
        let tokenBalance = await getMBTokenBalance(principalId);
        let isStakeValid : Bool = tokenBalance >= stake;
        if (tokenBalance < minimumAmountOfToken or not isStakeValid) {
            return #err("You need to have MB tokens to create a neuron")
        };

        if (U.safeGet(neuronIdHashMap, principalId, "0") != "0") {
            return #err("You already have a neuron")
        };

        let fee = await MBTOKENACTOR.icrc1_fee();

        ignore await MBTOKENACTOR.icrc1_transfer({
            amount = Int.abs(stake * 1000000) - fee;
            created_at_time = null;
            fee = ?fee;
            from_subaccount = ?get_subaccount_by_principal(caller);
            memo = null;
            to = {
                owner = caller;
                subaccount = null
            }
        });

        let neuronId = getNewNeuronID(principalId);

        //put neuron in hashmap
        neuronIdHashMap.put(principalId, Nat.toText(neuronId));
        neuronOwnerPrincipalHashMap.put(Nat.toText(neuronId), principalId);
        neuronSubAccountHashMap.put(Nat.toText(neuronId), get_subaccount_by_principal(caller));
        neuronCreatedHashMap.put(Nat.toText(neuronId), time);
        neuronStakeHashMap.put(Nat.toText(neuronId), Int.abs(stake));
        neuronDisolveDelayHashMap.put(Nat.toText(neuronId), lockTimeInMonths);
        neuronStateHashMap.put(Nat.toText(neuronId), #locked);

        let neuron = buildNeuron(principalId);

        #ok(neuron)
    };

    public shared ({ caller }) func dissolveNeuron(neuronId : Text) : async Result.Result<Neuron, Text> {
        let owner = U.safeGet(neuronOwnerPrincipalHashMap, neuronId, "");
        if (owner != Principal.toText(caller)) {
            return #err("Unauthorized!")
        };
        switch (neuronDisolveDelayHashMap.get(neuronId)) {
            case (null) {
                //if the locked time is deleted, user is started to dissolve already
                #err("The neuron is not locked!")
            };
            case (?lockedTime) {
                //it's locked
                let now = Time.now();
                neuronIsDisolvedDateHashMap.put(neuronId, now + lockedTime);
                neuronDisolveDelayHashMap.delete(neuronId);
                let neuron = buildNeuron(owner);
                #ok(neuron)
            }
        }
    };

    private func getNeuronBalance(user : Principal) : async Nat {
        return await MBTOKENACTOR.icrc1_balance_of({
            owner = Principal.fromActor(Dao);
            subaccount = ?get_subaccount_by_principal(user)
        });

    };

    private func unwrap<T>(val : ?T) : T {
        Option.unwrap(val)
    };
    public shared ({ caller }) func updateNeuron(neuronId : Text, stopDissolving : Bool, newLockTime : ?Int) : async Result.Result<Neuron, Text> {
        let owner = U.safeGet(neuronOwnerPrincipalHashMap, neuronId, "");
        let six_months = 15778800000000000;
        if (owner != Principal.toText(caller)) {
            return #err("Unauthorized!")
        };
        switch (newLockTime) {
            case (?lockTime) {
                switch (neuronDisolveDelayHashMap.get(neuronId)) {
                    case (null) {
                        let now = Time.now();
                        //neuron is dissolving or already dissolved
                        //this will not trap because if an neuron is not locked, it definitely has a dissolve date
                        let dissolveDate = unwrap(neuronIsDisolvedDateHashMap.get(neuronId));

                        if (dissolveDate > now) {
                            //status: dissolving
                            if (stopDissolving) {
                                let alreadyLockedTime = dissolveDate - now;
                                //if user is trying to decrease the lock time, ignore the input and use the existing locked time
                                let newLockedTime = if (alreadyLockedTime > lockTime) {
                                    alreadyLockedTime
                                } else { lockTime };
                                //control the neuron balance and update the balances hashmap with the balance fetched from token canister
                                let neuronBalance = await getNeuronBalance(Principal.fromText(owner));

                                //stop dissolving buy deleting the dissolve date and adding the locked time
                                neuronIsDisolvedDateHashMap.delete(neuronId);
                                neuronDisolveDelayHashMap.put(neuronId, newLockedTime);
                                neuronStakeHashMap.put(neuronId, neuronBalance);
                                //updated locked time and fetched the neuron balance from token canister
                                //return the neuron
                                return #ok(buildNeuron(neuronId))
                            } else {
                                //if user is trying to decrease the dissolving delay, ignore the input and use the existing dissolve date
                                let newDissolveDate = if (dissolveDate - now > lockTime) {
                                    dissolveDate
                                } else { now + lockTime };

                                //control the neuron balance and update the balances hashmap with the balance fetched from token canister
                                let neuronBalance = await getNeuronBalance(Principal.fromText(owner));

                                //update the fields
                                neuronIsDisolvedDateHashMap.put(neuronId, newDissolveDate);
                                neuronStakeHashMap.put(neuronId, neuronBalance);

                                //return the neuron
                                return #ok(buildNeuron(neuronId));

                            };

                        } else {
                            //status: dissolved
                            //since it's already dissolved, ignore stopDissolving argument
                            //lock it
                            if (six_months > lockTime or six_months * 16 < lockTime) {
                                return #err("Dissolve delay can not be higher than 8 years or lower than 6 months!")
                            };
                            let neuronBalance = await getNeuronBalance(caller);
                            if (neuronBalance < minimumAmountOfToken and neuronBalance != 0) {
                                let fee = await MBTOKENACTOR.icrc1_fee();
                                //send back tokens
                                ignore await MBTOKENACTOR.icrc1_transfer({
                                    amount = neuronBalance - fee;
                                    created_at_time = null;
                                    fee = null;
                                    from_subaccount = ?get_subaccount_by_principal(caller);
                                    memo = null;
                                    to = {
                                        owner = caller;
                                        subaccount = null
                                    }
                                });
                                return #err("Locked token is too low!")
                            };
                            //stop dissolving buy deleting the dissolve date and adding the locked time
                            neuronIsDisolvedDateHashMap.delete(neuronId);
                            neuronDisolveDelayHashMap.put(neuronId, lockTime);
                            neuronStakeHashMap.put(neuronId, neuronBalance);
                            //updated locked time and fetched the neuron balance from token canister
                            //return the neuron
                            return #ok(buildNeuron(neuronId))
                        }
                    };
                    case (?alreadyLockedTime) {

                        //status: locked
                        if (lockTime > 16 * six_months) {
                            return #err("An neuron can not be locked more than 8 years!")
                        };
                        //if user is trying to decrease the lock time, ignore the input and use the existing locked time
                        //put it to the hasmap
                        let newLockedTime = if (alreadyLockedTime > lockTime) {
                            alreadyLockedTime
                        } else { lockTime };
                        //control the neuron balance and update the balances hashmap with the balance fetched from token canister
                        let neuronBalance = await getNeuronBalance(Principal.fromText(owner));

                        neuronDisolveDelayHashMap.put(neuronId, newLockedTime);
                        neuronStakeHashMap.put(neuronId, neuronBalance);
                        //updated locked time and fetched the neuron balance from token canister
                        //return the neuron
                        return #ok(buildNeuron(neuronId))
                    }
                }
            };
            case (null) {
                //user didn't specify any new time for dissolve delay
                //if stopDissolving is true and neuron status is dissolving, lock the neuron
                //if stopDissolving is false do nothing
                if (stopDissolving) {

                    let now = Time.now();
                    let dissolveDate = U.safeGet(neuronIsDisolvedDateHashMap, neuronId, 0);
                    if (dissolveDate == 0) {
                        //status: locked
                        return #err("This neuron has already locked!")
                    };
                    if (dissolveDate < now) {
                        //status: dissolved
                        //since this is a dissolved neuron and user didn't specify any lock time, throw an error because user needs to specify a lockTime to lock the token
                        return #err("This neuron has dissolved. LockTime not found!")
                    } else {
                        //status: dissolving
                        //stop dissolving by deleting the dissolve date and adding the locked time
                        neuronIsDisolvedDateHashMap.delete(neuronId);
                        neuronDisolveDelayHashMap.put(neuronId, dissolveDate - now)
                    }
                };
                //just control the neuron balance and return the neuron
                let neuronBalance = await getNeuronBalance(Principal.fromText(owner));
                neuronStakeHashMap.put(neuronId, neuronBalance);
                return #ok(buildNeuron(neuronId))
            }
        }
    };

    private func getNeuronVotePower(neuronId : Text) : Int {
        let six_months = 15778800000000000;
        let neuronOwner = unwrap(neuronOwnerPrincipalHashMap.get(neuronId));
        switch (neuronStakeHashMap.get(neuronId)) {
            case (?lockedTime) {
                let dissolve_delay_bonus = Float.fromInt(lockedTime) / Float.fromInt(six_months * 15) * 0.94;
                let age_bonus = if (lockedTime > six_months * 8) { 1.25 } else {
                    Float.fromInt(lockedTime) / Float.fromInt(six_months * 8) * 0.25 + 1
                };
                let neuron_locked = U.safeGet(neuronStakeHashMap, neuronId, 0);
                let neuron_locked_factor = Float.fromInt(neuron_locked) / 100000000;
                Float.toInt(dissolve_delay_bonus * age_bonus * neuron_locked_factor)
            };
            case (null) {
                switch (neuronIsDisolvedDateHashMap.get(neuronId)) {
                    case (?dissolveDate) {
                        if (Int.greater(six_months, dissolveDate - Time.now())) {
                            return 0
                        } else {
                            let lockedTime = dissolveDate - Time.now();
                            let dissolve_delay_bonus = Float.fromInt(lockedTime) / Float.fromInt(six_months * 15) * 0.94;
                            let age_bonus = if (lockedTime > six_months * 8) {
                                1.25
                            } else {
                                Float.fromInt(lockedTime) / Float.fromInt(six_months * 8) * 0.25 + 1
                            };
                            let neuron_locked = U.safeGet(neuronStakeHashMap, neuronId, 0);
                            let neuron_locked_factor = Float.fromInt(neuron_locked) / 100000000;
                            Float.toInt(dissolve_delay_bonus * age_bonus * neuron_locked_factor)
                        }
                    };
                    case (null) {
                        return 0
                    }
                }
            }
        }
    };

    //     var chatIdHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash);
    //     var chatOwnerPrincipalHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash);
    //     var chatCreatedHashMap = HashMap.HashMap<Text, Int>(maxHashmapSize, isEq, Text.hash);
    //     var chatMessageHashMap = HashMap.HashMap<Text, Text>(maxHashmapSize, isEq, Text.hash);

    //chat sections.. because we're going to want to discuss these important title changes 💀
    stable var chatId = 0;

    func getChatId() : async (Nat) {
        chatId += 1;
        return chatId
    };

    public shared ({ caller }) func createMessage(message : Text) : async () {
        let chatIdNat = await getChatId();
        let chatId = Nat.toText(chatIdNat);
        let chatOwner = Principal.toText(caller);
        let chatMessage = message;
        let chatCreated = Time.now();
        chatIdHashMap.put(chatId, chatId);
        chatOwnerPrincipalHashMap.put(chatId, chatOwner);
        chatCreatedHashMap.put(chatId, chatCreated);
        chatMessageHashMap.put(chatId, chatMessage)
    };

    private func buildChat(chatId : Text) : PublicChat {
        let chatOwner = U.safeGet(chatOwnerPrincipalHashMap, chatId, "");
        let chatCreated = U.safeGet(chatCreatedHashMap, chatId, 0);
        let chatMessage = U.safeGet(chatMessageHashMap, chatId, "");

        return {
            chatId = U.textToNat(chatId);
            ownerPrincipal = chatOwner;
            created = chatCreated;
            message = chatMessage
        }
    };

    public shared query func getChat() : async ([PublicChat]) {
        var chatBuffer = Buffer.Buffer<PublicChat>(0);

        for (chatId in chatIdHashMap.keys()) {
            let chat = buildChat(chatId);
            chatBuffer.put(U.textToNat(chatId), chat)
        };
        return chatBuffer.toArray()
    };

}

//todo test neuron functions, state, dissolve, vote
//todo test chat functions, state, create, get
// make vote perecents normal
