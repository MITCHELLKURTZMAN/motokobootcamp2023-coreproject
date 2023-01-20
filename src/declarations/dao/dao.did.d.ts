import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Neuron {
  'id' : bigint,
  'created' : bigint,
  'vote' : bigint,
  'stake' : bigint,
  'state' : NeuronState,
  'stakeReleaseDate' : bigint,
  'proposalId' : bigint,
  'principalId' : string,
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
export type Result = { 'ok' : Proposal } |
  { 'err' : string };
export type Result_1 = { 'ok' : null } |
  { 'err' : string };
export type Result_2 = { 'ok' : string } |
  { 'err' : string };
export type Result_3 = { 'ok' : Array<string> } |
  { 'err' : string };
export type Result_4 = { 'ok' : Array<Proposal> } |
  { 'err' : string };
export type Result_5 = { 'ok' : Neuron } |
  { 'err' : string };
export type VoteOptions = { 'no' : null } |
  { 'yes' : null };
export interface _SERVICE {
  'adminReset' : ActorMethod<[], undefined>,
  'createNeuron' : ActorMethod<[bigint], Result_5>,
  'getMBTokenBalance' : ActorMethod<[string], bigint>,
  'getPageText' : ActorMethod<[], string>,
  'getProposalId' : ActorMethod<[], string>,
  'get_all_proposals' : ActorMethod<[], Result_4>,
  'get_proposal' : ActorMethod<[bigint], Result>,
  'get_votes_by_principal' : ActorMethod<[], Result_3>,
  'quadratic_voting' : ActorMethod<[VoteOptions, bigint], Result_2>,
  'submit_proposal' : ActorMethod<[string], Result_1>,
  'update_dao_text' : ActorMethod<[], undefined>,
  'vote' : ActorMethod<[bigint, VoteOptions, string, bigint], Result>,
  'whoAmI' : ActorMethod<[], string>,
}
