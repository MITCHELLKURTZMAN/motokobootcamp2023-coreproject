import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Neuron {
  'id' : bigint,
  'created' : bigint,
  'subAccount' : Subaccount,
  'ownerPrincipal' : string,
  'disolveDelay' : bigint,
  'stake' : bigint,
  'state' : NeuronState,
}
export type NeuronState = { 'locked' : null } |
  { 'dissolved' : null } |
  { 'dissolving' : null };
export interface Proposal {
  'id' : bigint,
  'status' : string,
  'vote' : bigint,
  'pageText' : string,
}
export interface PublicChat {
  'created' : bigint,
  'ownerPrincipal' : string,
  'message' : string,
  'chatId' : bigint,
}
export type Result = { 'ok' : Proposal } |
  { 'err' : string };
export type Result_1 = { 'ok' : Neuron } |
  { 'err' : string };
export type Result_2 = { 'ok' : null } |
  { 'err' : string };
export type Result_3 = { 'ok' : string } |
  { 'err' : string };
export type Result_4 = { 'ok' : Array<string> } |
  { 'err' : string };
export type Result_5 = { 'ok' : Array<Proposal> } |
  { 'err' : string };
export type Subaccount = Uint8Array;
export interface _SERVICE {
  'createMessage' : ActorMethod<[string], undefined>,
  'createNeuron' : ActorMethod<[bigint, bigint], Result_1>,
  'dissolveNeuron' : ActorMethod<[string], Result_1>,
  'getChat' : ActorMethod<[], Array<PublicChat>>,
  'getMBTokenBalance' : ActorMethod<[string], bigint>,
  'getNeuron' : ActorMethod<[], Result_1>,
  'getPageText' : ActorMethod<[], string>,
  'getPrincipalId' : ActorMethod<[], string>,
  'getProposalId' : ActorMethod<[], string>,
  'getVotePercent' : ActorMethod<[bigint], bigint>,
  'get_all_proposals' : ActorMethod<[], Result_5>,
  'get_proposal' : ActorMethod<[bigint], Result>,
  'get_subaccount_to_lock_tokens' : ActorMethod<[], Uint8Array>,
  'get_votes_by_principal' : ActorMethod<[], Result_4>,
  'isblackhole' : ActorMethod<[], string>,
  'neuronVote' : ActorMethod<[boolean, bigint], Result_3>,
  'quadratic_voting' : ActorMethod<[boolean, bigint], Result_3>,
  'submit_proposal' : ActorMethod<[string], Result_2>,
  'updateNeuron' : ActorMethod<[string, boolean, [] | [bigint]], Result_1>,
  'update_dao_text' : ActorMethod<[], undefined>,
  'vote' : ActorMethod<[bigint, boolean, string, bigint], Result>,
  'whoAmI' : ActorMethod<[], string>,
}
