export const idlFactory = ({ IDL }) => {
  const NeuronState = IDL.Variant({
    'locked' : IDL.Null,
    'dissolved' : IDL.Null,
    'dissolving' : IDL.Null,
  });
  const Neuron = IDL.Record({
    'id' : IDL.Nat,
    'created' : IDL.Int,
    'vote' : IDL.Int,
    'stake' : IDL.Nat,
    'state' : NeuronState,
    'stakeReleaseDate' : IDL.Int,
    'proposalId' : IDL.Nat,
    'principalId' : IDL.Text,
  });
  const Result_5 = IDL.Variant({ 'ok' : Neuron, 'err' : IDL.Text });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'status' : IDL.Text,
    'vote' : IDL.Int,
    'pageText' : IDL.Text,
  });
  const Result_4 = IDL.Variant({ 'ok' : IDL.Vec(Proposal), 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : Proposal, 'err' : IDL.Text });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Vec(IDL.Text), 'err' : IDL.Text });
  const VoteOptions = IDL.Variant({ 'no' : IDL.Null, 'yes' : IDL.Null });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'adminReset' : IDL.Func([], [], ['oneway']),
    'createNeuron' : IDL.Func([IDL.Int], [Result_5], []),
    'getMBTokenBalance' : IDL.Func([IDL.Text], [IDL.Nat], []),
    'getPageText' : IDL.Func([], [IDL.Text], ['query']),
    'getProposalId' : IDL.Func([], [IDL.Text], ['query']),
    'get_all_proposals' : IDL.Func([], [Result_4], []),
    'get_proposal' : IDL.Func([IDL.Nat], [Result], []),
    'get_votes_by_principal' : IDL.Func([], [Result_3], []),
    'quadratic_voting' : IDL.Func([VoteOptions, IDL.Nat], [Result_2], []),
    'submit_proposal' : IDL.Func([IDL.Text], [Result_1], []),
    'update_dao_text' : IDL.Func([], [], []),
    'vote' : IDL.Func([IDL.Nat, VoteOptions, IDL.Text, IDL.Nat], [Result], []),
    'whoAmI' : IDL.Func([], [IDL.Text], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
