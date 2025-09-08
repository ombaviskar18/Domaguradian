import './ConfirmedContent.css';

import clsx from 'clsx';
import { useEffect, useMemo, useState } from 'react';

import { Button } from './components/Button';
import { IconReceived, IconSpinner } from './components/icons';
import {
  type SupportedChain,
  SONIC_TESTNET_EXPLORER_URL as ZETACHAIN_ATHENS_BLOCKSCOUT_EXPLORER_URL,
} from './constants/chains';
import { type CrossChainTxResponse } from './types/cctx';

const CCTX_POLLING_URL =
  'https://rpc.testnet.soniclabs.com';

interface ConfirmedContentProps {
  supportedChain: SupportedChain | undefined;
  connectedChainTxHash: string;
  handleSendAnotherMessage: () => void;
  stringValue: string;
}

const MAX_STRING_LENGTH = 20;

export function ConfirmedContent({
  supportedChain,
  connectedChainTxHash,
  handleSendAnotherMessage,
  stringValue,
}: ConfirmedContentProps) {
  const [zetachainTxHash, setZetachainTxHash] = useState<string | null>(null);
  const renderString = useMemo(() => {
    if (stringValue.length > MAX_STRING_LENGTH) {
      return stringValue.slice(0, MAX_STRING_LENGTH) + '...';
    }
    return stringValue;
  }, [stringValue]);

  // Polling placeholder (disabled for Sonic)
  useEffect(() => {
    setZetachainTxHash(connectedChainTxHash || null);
  }, [connectedChainTxHash, zetachainTxHash]);

  return (
    <div className="confirmed-content">
      <IconReceived />
      <h2 className="confirmed-content-title">
        "{renderString}" {!zetachainTxHash ? 'in Transit' : 'Received'}
      </h2>
      <div className="confirmed-content-links-container">
        {supportedChain && (
          <div className="confirmed-content-link-chain">
            {!connectedChainTxHash && <IconSpinner />}
            <a
              href={`${supportedChain.explorerUrl}${connectedChainTxHash}`}
              target="_blank"
              rel="noreferrer noopener"
              className={clsx('confirmed-content-link', {
                'confirmed-content-link-enabled': connectedChainTxHash,
                'confirmed-content-link-disabled': !connectedChainTxHash,
              })}
            >
              View on {supportedChain.name}
            </a>
          </div>
        )}
        {connectedChainTxHash && (
          <div className="confirmed-content-link-chain">
            {!zetachainTxHash && <IconSpinner />}
            <a
              href={`${ZETACHAIN_ATHENS_BLOCKSCOUT_EXPLORER_URL}${zetachainTxHash}`}
              target="_blank"
              rel="noreferrer noopener"
              className={clsx('confirmed-content-link', {
                'confirmed-content-link-enabled': zetachainTxHash,
                'confirmed-content-link-disabled': !zetachainTxHash,
              })}
            >
              View on SonicChain
            </a>
          </div>
        )}
      </div>
      <Button
        type="button"
        variant="thin"
        disabled={!connectedChainTxHash || !zetachainTxHash}
        onClick={() => {
          handleSendAnotherMessage();
          setZetachainTxHash(null);
        }}
      >
        Send Another
      </Button>
    </div>
  );
}
