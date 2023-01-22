export const idlFactory = ({ IDL }) => {
  const Subaccount = IDL.Vec(IDL.Nat8);
  const NeuronState = IDL.Variant({
    'locked' : IDL.Null,
    'dissolved' : IDL.Null,
    'dissolving' : IDL.Null,
  });
  const Neuron = IDL.Record({
    'id' : IDL.Nat,
    'created' : IDL.Int,
    'subAccount' : Subaccount,
    'ownerPrincipal' : IDL.Text,
    'disolveDelay' : IDL.Int,
    'stake' : IDL.Nat,
    'state' : NeuronState,
  });
  const Result_1 = IDL.Variant({ 'ok' : Neuron, 'err' : IDL.Text });
  const PublicChat = IDL.Record({
    'created' : IDL.Int,
    'ownerPrincipal' : IDL.Text,
    'message' : IDL.Text,
    'chatId' : IDL.Nat,
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'status' : IDL.Text,
    'vote' : IDL.Int,
    'pageText' : IDL.Text,
  });
  const Result_5 = IDL.Variant({ 'ok' : IDL.Vec(Proposal), 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : Proposal, 'err' : IDL.Text });
  const Result_4 = IDL.Variant({ 'ok' : IDL.Vec(IDL.Text), 'err' : IDL.Text });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'createMessage' : IDL.Func([IDL.Text], [], []),
    'createNeuron' : IDL.Func([IDL.Int, IDL.Int], [Result_1], []),
    'dissolveNeuron' : IDL.Func([IDL.Text], [Result_1], []),
    'getChat' : IDL.Func([], [IDL.Vec(PublicChat)], ['query']),
    'getMBTokenBalance' : IDL.Func([IDL.Text], [IDL.Nat], []),
    'getNeuron' : IDL.Func([], [Result_1], ['query']),
    'getPageText' : IDL.Func([], [IDL.Text], ['query']),
    'getPrincipalId' : IDL.Func([], [IDL.Text], ['query']),
    'getProposalId' : IDL.Func([], [IDL.Text], ['query']),
    'getVotePercent' : IDL.Func([IDL.Nat], [IDL.Int], ['query']),
    'get_all_proposals' : IDL.Func([], [Result_5], ['query']),
    'get_proposal' : IDL.Func([IDL.Nat], [Result], ['query']),
    'get_subaccount_to_lock_tokens' : IDL.Func(
        [],
        [IDL.Vec(IDL.Nat8)],
        ['query'],
      ),
    'get_votes_by_principal' : IDL.Func([], [Result_4], ['query']),
    'isblackhole' : IDL.Func([], [IDL.Text], ['query']),
    'neuronVote' : IDL.Func([IDL.Bool, IDL.Nat], [Result_3], []),
    'quadratic_voting' : IDL.Func([IDL.Bool, IDL.Nat], [Result_3], []),
    'submit_proposal' : IDL.Func([IDL.Text], [Result_2], []),
    'updateNeuron' : IDL.Func(
        [IDL.Text, IDL.Bool, IDL.Opt(IDL.Int)],
        [Result_1],
        [],
      ),
    'update_dao_text' : IDL.Func([], [], []),
    'vote' : IDL.Func([IDL.Nat, IDL.Bool, IDL.Text, IDL.Nat], [Result], []),
    'whoAmI' : IDL.Func([], [IDL.Text], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
