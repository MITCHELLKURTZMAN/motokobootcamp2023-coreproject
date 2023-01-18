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

    // var proposalList : List.List<Proposal> = List.nil<Proposal>();
    var proposalHashMap = HashMap.HashMap<Text, Proposal>(maxHashmapSize, isEq, Text.hash);

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

    public shared func getMBTokenBalance(owner : Text) : async Nat {
        let balance = await MBTOKENACTOR.icrc1_balance_of({
            owner = Principal.fromText(owner);
            subaccount = null
        });
        balance
    };

    public shared ({ caller }) func submit_proposal(text : Text) : async Result.Result<(), Text> {

        let principalId = Principal.toText(caller);
        let tokenBalance = await getMBTokenBalance(principalId);
        if (tokenBalance == 0) {
            return #err("You need to have MB tokens to submit a proposal")
        };

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
        if (not isMember(caller)) {
            return #err(Unauthorized)
        };

        let proposal = U.safeGet(proposalHashMap, Nat.toText(id), { id = 0; pageText = ""; vote = 0; status = "" });

        #ok(proposal)
    };

    public shared ({ caller }) func get_all_proposals() : async Result.Result<[Proposal], Text> {

        let proposalList = proposalHashMap.vals();
        let proposalArray = Iter.toArray(proposalList);

        #ok(proposalArray);

    };

    public shared ({ caller }) func vote(id : Nat, vote : Text) : async Result.Result<Proposal, Text> {

        //todo scale voting power correctly for token balance
        //temp return for voting power
        let principalId = Principal.toText(caller);
        let tokenBalance = await getMBTokenBalance(principalId);
        if (tokenBalance == 0) {
            return #err("You need to have MB tokens to vote on a proposal")
        };

        let votingPower = if (vote == "y") { 1 * tokenBalance } else {
            1 * tokenBalance
        };

        let proposal = buildProposal(id);

        if (proposal.status == "Pending") {

            let currentVote = proposal.vote;

            let newVote = currentVote + votingPower;

            voteHashMap.put(Nat.toText(id), newVote);

            if (newVote >= 100) {
                statusHashMap.put(Nat.toText(id), "Passed");
                pageText := proposal.pageText
            };

            if (newVote <= -100) {
                statusHashMap.put(Nat.toText(id), "Rejected")
            };

            return #ok(buildProposal(id));

        } else {
            return #err("Proposal is " # proposal.status)
        };

    };

    // member functions

    private func isMember(caller : Principal) : Bool {
        var c = Principal.toText(caller);
        var exists = List.find<Text>(members, func(val : Text) : Bool { val == c });
        exists != null
    };

    public shared query ({ caller }) func getMembers() : async Result.Result<[Text], Text> {
        if (not isMember(caller)) {
            return #err(Unauthorized)
        };

        #ok(List.toArray(members))
    };

    public shared ({ caller }) func registerMember(id : Text) : async Result.Result<(), Text> {

        if (List.size<Text>(members) > 0 and not isMember(caller)) {
            return #err(Unauthorized)
        };

        if (not List.some<Text>(members, func(val : Text) : Bool { val == id })) {
            members := List.push<Text>(id, members)
        };

        #ok()
    };

    public shared ({ caller }) func unregisterMember(id : Text) : async Result.Result<(), Text> {
        if (not isMember(caller)) {
            return #err(Unauthorized)
        };
        members := List.filter<Text>(members, func(val : Text) : Bool { val != id });
        #ok()
    };

};

//notes to self=
// first i need basic crud, create prop, read prop, update prop
// create prop will be a page text
// read prop will be a list of values
//updating prop will be a vote
//
