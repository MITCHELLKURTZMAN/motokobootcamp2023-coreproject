export const idlFactory = ({ IDL }) => {
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const HttpRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'status_code' : IDL.Nat16,
  });
  return IDL.Service({
    'http_request' : IDL.Func([HttpRequest], [HttpResponse], ['query']),
    'update_dao_text' : IDL.Func([IDL.Text], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
