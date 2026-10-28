# Sawa Wallet

**Ingabire Esther** · 27202 · Group B

A MoMo-style wallet. Money comes in, you send it to a friend, and you cash out at an agent. The balance is calculated from the transactions, and it is never changed until every check has passed.

Project: **MoMo Wallet** (Week 2 mini project, plus Week 3 saving and a live API).

GitHub: [Esther-ingabire/momo_wallet](https://github.com/Esther-ingabire/momo_wallet)

## Features

- Starts at 10,000 RWF with sample transactions, newest first.
- Balance card, total in, total out, and the lowest balance ever reached.
- Filter: All, IN, or OUT. An empty filter says so.
- Receive money: description required, amount a whole number above 0. Saved as an IN.
- Send money: the phone number must be exactly 10 digits and start with 078 or 079, and the amount must be at least 100 RWF. A 100 RWF send fee is its own OUT. A refusal says which rule failed.
- Cash out: the amount must be a multiple of 100. The screen shows the notes (5,000, 2,000, 1,000, 500, 100) biggest first, then Confirm. An OUT bigger than the balance is refused.
- Tap a transaction for details. Hold, or Delete on the details screen, removes it, with Undo. A delete that would make the balance negative at any point in the history is refused.
- Every change is saved on the phone. Close the app and open it again: the same transactions, balance, and statistics are still there. The first open, before anything is saved, shows the sample data.
- Today's dollar rate, asked from a live server: a spinner while it loads, a message and Retry when it fails, and the rate plus what the balance is worth in USD when it arrives.

## Screenshots

Save the six emulator pictures in `screenshots` inside this project, next to `pubspec.yaml`. The folder is `C:\Users\Administrator\Desktop\momo_wallet\screenshots`. Use these file names.

![Wallet home, with the balance and today's dollar rate](screenshots/01-wallet-home.png)

![A send that is refused](screenshots/02-send-refused.png)

![Cash out notes](screenshots/03-cash-out-notes.png)

![Transaction details](screenshots/04-transaction-details.png)

![The same transactions after a restart](screenshots/05-after-restart.png)

![The dollar rate when there is no internet](screenshots/06-rate-offline.png)

## Think

**Why must every check happen before any money moves? What would go wrong if one check came after?**

The wallet only adds a transaction after the phone number, the amount, and the balance have all passed. The balance is not stored on its own: it is added up from the transactions. If a bad send was recorded first and the phone number was checked afterwards, the money would already be gone. A crash between those two lines would leave the wallet wrong, and Undo would be guessing. Checking first means a refusal changes nothing.

**Your lowest-balance statistic needs a starting value. What did you start it at, and why not 0?**

It starts at 10,000 RWF, the opening balance, before any transaction is applied. The wallet already holds that money. Starting at 0 would report a lowest balance that never happened. The number only moves when a later balance is actually smaller.
