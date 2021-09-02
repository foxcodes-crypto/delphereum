{******************************************************************************}
{                                                                              }
{                                  Delphereum                                  }
{                                                                              }
{             Copyright(c) 2018 Stefan van As <svanas@runbox.com>              }
{           Github Repository <https://github.com/svanas/delphereum>           }
{                                                                              }
{   Distributed under Creative Commons NonCommercial (aka CC BY-NC) license.   }
{                                                                              }
{******************************************************************************}

unit web3.eth;

{$I web3.inc}

interface

uses
  // Velthuis' BigNumbers
  Velthuis.BigIntegers,
  // web3
  web3,
  web3.eth.types;

const
  BLOCK_EARLIEST = 'earliest';
  BLOCK_LATEST   = 'latest';
  BLOCK_PENDING  = 'pending';

const
  BLOCKS_PER_DAY = 5760; // 4 * 60 * 24

const
  ADDRESS_ZERO: TAddress = '0x0000000000000000000000000000000000000000';
  BYTES32_ZERO: TBytes32 = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

function  blockNumber(client: IWeb3): BigInteger; overload;               // blocking
procedure blockNumber(client: IWeb3; callback: TAsyncQuantity); overload; // async

procedure getBalance(client: IWeb3; address: TAddress; callback: TAsyncQuantity); overload;
procedure getBalance(client: IWeb3; address: TAddress; const block: string; callback: TAsyncQuantity); overload;

procedure getTransactionCount(client: IWeb3; address: TAddress; callback: TAsyncQuantity); overload;
procedure getTransactionCount(client: IWeb3; address: TAddress; const block: string; callback: TAsyncQuantity); overload;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncString); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncString); overload;
procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncString); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncString); overload;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncQuantity); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncQuantity); overload;
procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncQuantity); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncQuantity); overload;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncBoolean); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncBoolean); overload;
procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncBoolean); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncBoolean); overload;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncBytes32); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncBytes32); overload;
procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncBytes32); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncBytes32); overload;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncTuple); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncTuple); overload;
procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncTuple); overload;
procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncTuple); overload;

function sign(privateKey: TPrivateKey; const msg: string): TSignature;

// transact with a non-payable function.
// default to the median gas price from the latest blocks.
// default to a 600,000 gas limit.
procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  const func: string;
  args      : array of const;
  callback  : TAsyncReceipt); overload;

// transact with a non-payable function.
// default to the median gas price from the latest blocks.
procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  const func: string;
  args      : array of const;
  gasLimit  : TWei;
  callback  : TAsyncReceipt); overload;

// transact with a payable function.
// default to the median gas price from the latest blocks.
// default to a 600,000 gas limit.
procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  value     : TWei;
  const func: string;
  args      : array of const;
  callback  : TAsyncReceipt); overload;

// transact with a payable function.
// default to the median gas price from the latest blocks.
procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  value     : TWei;
  const func: string;
  args      : array of const;
  gasLimit  : TWei;
  callback  : TAsyncReceipt); overload;

procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  value     : TWei;
  const func: string;
  args      : array of const;
  gasPrice  : TWei;
  gasLimit  : TWei;
  callback  : TAsyncReceipt); overload;

procedure write(
  client      : IWeb3;
  from        : TPrivateKey;
  &to         : TAddress;
  value       : TWei;
  const data  : string;
  gasPrice    : TWei;
  gasLimit    : TWei;
  estimatedGas: TWei;
  callback    : TAsyncReceipt); overload;

implementation

uses
  // Delphi
  System.JSON,
  System.SysUtils,
  // CryptoLib4Pascal
  ClpBigInteger,
  ClpIECPrivateKeyParameters,
  // web3
  web3.crypto,
  web3.eth.abi,
  web3.eth.crypto,
  web3.eth.gas,
  web3.eth.tx,
  web3.json,
  web3.json.rpc,
  web3.utils;

function blockNumber(client: IWeb3): BigInteger;
var
  obj: TJsonObject;
begin
  obj := client.Call('eth_blockNumber', []);
  if Assigned(obj) then
  try
    Result := web3.json.getPropAsStr(obj, 'result');
  finally
    obj.Free;
  end;
end;

procedure blockNumber(client: IWeb3; callback: TAsyncQuantity);
begin
  client.Call('eth_blockNumber', [], procedure(resp: TJsonObject; err: IError)
  begin
    if Assigned(err) then
      callback(0, err)
    else
      callback(web3.json.getPropAsStr(resp, 'result'), nil);
  end);
end;

procedure getBalance(client: IWeb3; address: TAddress; callback: TAsyncQuantity);
begin
  getBalance(client, address, BLOCK_LATEST, callback);
end;

procedure getBalance(client: IWeb3; address: TAddress; const block: string; callback: TAsyncQuantity);
begin
  client.Call('eth_getBalance', [address, block], procedure(resp: TJsonObject; err: IError)
  begin
    if Assigned(err) then
      callback(0, err)
    else
      callback(web3.json.getPropAsStr(resp, 'result'), nil);
  end);
end;

procedure getTransactionCount(client: IWeb3; address: TAddress; callback: TAsyncQuantity);
begin
  getTransactionCount(client, address, BLOCK_LATEST, callback);
end;

// returns the number of transations *sent* from an address
procedure getTransactionCount(client: IWeb3; address: TAddress; const block: string; callback: TAsyncQuantity);
begin
  client.Call('eth_getTransactionCount', [address, block], procedure(resp: TJsonObject; err: IError)
  begin
    if Assigned(err) then
      callback(0, err)
    else
      callback(web3.json.getPropAsStr(resp, 'result'), nil);
  end);
end;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncString);
begin
  call(client, ADDRESS_ZERO, &to, func, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncString);
begin
  call(client, from, &to, func, BLOCK_LATEST, args, callback);
end;

procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncString);
begin
  call(client, ADDRESS_ZERO, &to, func, block, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncString);
var
  abi: string;
  obj: TJsonObject;
begin
  // step #1: encode the function abi
  abi := web3.eth.abi.encode(func, args);
  // step #2: construct the transaction call object
  obj := web3.json.unmarshal(Format(
    '{"from": %s, "to": %s, "data": %s}', [
      web3.json.quoteString(string(from), '"'),
      web3.json.quoteString(string(&to), '"'),
      web3.json.quoteString(abi, '"')
    ]
  )) as TJsonObject;
  try
    // step #3: execute a message call (without creating a transaction on the blockchain)
    client.Call('eth_call', [obj, block], procedure(resp: TJsonObject; err: IError)
    begin
      if Assigned(err) then
        callback('', err)
      else
        callback(web3.json.getPropAsStr(resp, 'result'), nil);
    end);
  finally
    obj.Free;
  end;
end;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncQuantity);
begin
  call(client, ADDRESS_ZERO, &to, func, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncQuantity);
begin
  call(client, from, &to, func, BLOCK_LATEST, args, callback);
end;

procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncQuantity);
begin
  call(client, ADDRESS_ZERO, &to, func, block, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncQuantity);
begin
  call(client, from, &to, func, block, args, procedure(const hex: string; err: IError)
  var
    buf: TBytes;
  begin
    if Assigned(err) then
      callback(0, err)
    else
      if (hex = '') or (hex = '0x') then
        callback(0, nil)
      else
      begin
        buf := web3.utils.fromHex(hex);
        if Length(buf) <= 32 then
          callback(hex, nil)
        else
          callback(web3.utils.toHex(Copy(buf, 0, 32)), nil);
      end;
  end);
end;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncBoolean);
begin
  call(client, ADDRESS_ZERO, &to, func, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncBoolean);
begin
  call(client, from, &to, func, BLOCK_LATEST, args, callback);
end;

procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncBoolean);
begin
  call(client, ADDRESS_ZERO, &to, func, block, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncBoolean);
begin
  call(client, from, &to, func, block, args, procedure(const hex: string; err: IError)
  var
    buf: TBytes;
  begin
    if Assigned(err) then
      callback(False, err)
    else
    begin
      buf := web3.utils.fromHex(hex);
      callback((Length(buf) > 0) and (buf[High(buf)] <> 0), nil);
    end;
  end);
end;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncBytes32);
begin
  call(client, ADDRESS_ZERO, &to, func, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncBytes32);
begin
  call(client, from, &to, func, BLOCK_LATEST, args, callback);
end;

procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncBytes32);
begin
  call(client, ADDRESS_ZERO, &to, func, block, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncBytes32);
begin
  call(client, from, &to, func, block, args, procedure(const hex: string; err: IError)
  var
    buffer: TBytes;
    result: TBytes32;
  begin
    if Assigned(err) then
    begin
      callback(BYTES32_ZERO, err);
      EXIT;
    end;
    buffer := web3.utils.fromHex(hex);
    if Length(buffer) < 32 then
    begin
      callback(BYTES32_ZERO, nil);
      EXIT;
    end;
    Move(buffer[0], result[0], 32);
    callback(result, nil);
  end);
end;

procedure call(client: IWeb3; &to: TAddress; const func: string; args: array of const; callback: TAsyncTuple);
begin
  call(client, ADDRESS_ZERO, &to, func, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func: string; args: array of const; callback: TAsyncTuple);
begin
  call(client, from, &to, func, BLOCK_LATEST, args, callback);
end;

procedure call(client: IWeb3; &to: TAddress; const func, block: string; args: array of const; callback: TAsyncTuple);
begin
  call(client, ADDRESS_ZERO, &to, func, block, args, callback);
end;

procedure call(client: IWeb3; from, &to: TAddress; const func, block: string; args: array of const; callback: TAsyncTuple);
begin
  call(client, from, &to, func, block, args, procedure(const hex: string; err: IError)
  begin
    if Assigned(err) then
      callback([], err)
    else
      callback(TTuple.From(hex), nil);
  end);
end;

function sign(privateKey: TPrivateKey; const msg: string): TSignature;
var
  Signer   : TEthereumSigner;
  Signature: TECDsaSignature;
  v        : TBigInteger;
begin
  Signer := TEthereumSigner.Create;
  try
    Signer.Init(True, privateKey.Parameters);
    Signature := Signer.GenerateSignature(
      sha3(
        TEncoding.UTF8.GetBytes(
          #25 + 'Ethereum Signed Message:' + #10 + IntToStr(Length(msg)) + msg
        )
      )
    );
    v := Signature.rec.Add(TBigInteger.ValueOf(27));
    Result := TSignature(
      toHex(
        Signature.r.ToByteArrayUnsigned +
        Signature.s.ToByteArrayUnsigned +
        v.ToByteArrayUnsigned
      )
    );
  finally
    Signer.Free;
  end;
end;

procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  const func: string;
  args      : array of const;
  callback  : TAsyncReceipt);
begin
  write(client, from, &to, 0, func, args, callback);
end;

procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  const func: string;
  args      : array of const;
  gasLimit  : TWei;
  callback  : TAsyncReceipt);
begin
  write(client, from, &to, 0, func, args, gasLimit, callback);
end;

procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  value     : TWei;
  const func: string;
  args      : array of const;
  callback  : TAsyncReceipt);
begin
  write(client, from, &to, value, func, args, 600000, callback);
end;

procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  value     : TWei;
  const func: string;
  args      : array of const;
  gasLimit  : TWei;
  callback  : TAsyncReceipt);
var
  data: string;
begin
  data := web3.eth.abi.encode(func, args);
  web3.eth.gas.getGasPrice(client, procedure(gasPrice: BigInteger; err: IError)
  begin
    if Assigned(err) then
      callback(nil, err)
    else
      from.Address(procedure(addr: TAddress; err: IError)
      begin
        if Assigned(err) then
          callback(nil, err)
        else
          (*
          disabled 3/9/2021 due to issues with estimate retrieval failing JSON obj

          web3.eth.gas.estimateGas(
            client, addr, &to, data, gasLimit,
          procedure(estimatedGas: BigInteger; err: IError)
          begin
            if Assigned(err) then
              callback(nil, err)
            else
              write(client, from, &to, value, data, gasPrice, gasLimit, estimatedGas, callback);
          end);
          *)
            write(client, from, &to, value, data, gasPrice, gasLimit, BigInteger.Create(100000), callback);
      end);
  end);
end;

procedure write(
  client    : IWeb3;
  from      : TPrivateKey;
  &to       : TAddress;
  value     : TWei;
  const func: string;
  args      : array of const;
  gasPrice  : TWei;
  gasLimit  : TWei;
  callback  : TAsyncReceipt);
var
  data: string;
begin
  data := web3.eth.abi.encode(func, args);
  from.Address(procedure(addr: TAddress; err: IError)
  begin
    if Assigned(err) then
      callback(nil, err)
    else
      web3.eth.gas.estimateGas(
        client, addr, &to, data, gasLimit,
      procedure(estimatedGas: BigInteger; err: IError)
      begin
        if Assigned(err) then
          callback(nil, err)
        else
          write(client, from, &to, value, data, gasPrice, gasLimit, estimatedGas, callback);
      end);
  end);
end;

procedure write(
  client      : IWeb3;
  from        : TPrivateKey;
  &to         : TAddress;
  value       : TWei;
  const data  : string;
  gasPrice    : TWei;
  gasLimit    : TWei;
  estimatedGas: TWei;
  callback    : TAsyncReceipt);
begin
  from.Address(procedure(addr: TAddress; err: IError)
  begin
    if Assigned(err) then
      callback(nil, err)
    else
      web3.eth.tx.getNonce(client, addr, procedure(nonce: BigInteger; err: IError)
      begin
        if Assigned(err) then
          callback(nil, err)
        else
          signTransaction(client, nonce, from, &to, value, data, gasPrice, gasLimit, estimatedGas,
            procedure(const sig: string; err: IError)
            begin
              if Assigned(err) then
                callback(nil, err)
              else
                sendTransactionEx(client, sig, procedure(rcpt: ITxReceipt; err: IError)
                begin
                  if Assigned(err) and (err.Message = 'nonce too low') then
                    write(client, from, &to, value, data, gasPrice, gasLimit, estimatedGas, callback)
                  else
                    callback(rcpt, err);
                end);
            end);
      end);
  end);
end;

end.
