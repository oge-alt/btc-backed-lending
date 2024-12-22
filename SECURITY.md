# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of the BTC-Backed Lending Smart Contract seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Process

1. **DO NOT** create a public GitHub issue for the vulnerability
2. Email your findings to [security@example.com]
3. Include detailed steps to reproduce the issue
4. We will acknowledge receipt of your vulnerability report within 48 hours
5. We will send a more detailed response within 96 hours
6. We will keep you informed of the progress towards a fix
7. After the fix is deployed, we will publicly acknowledge your responsible disclosure

### What to Include in Your Report

- Type of issue (e.g., buffer overflow, SQL injection, or cross-site scripting)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### Smart Contract Specific Concerns

When reporting vulnerabilities related to the smart contract, please pay special attention to:

1. **Collateral Management**

   - Issues with collateral locking/unlocking
   - Potential double-spending vulnerabilities
   - Collateral ratio calculation errors

2. **Loan Processing**

   - Interest calculation vulnerabilities
   - Loan repayment processing issues
   - Liquidation threshold problems

3. **Access Control**

   - Authorization bypass possibilities
   - Privilege escalation vulnerabilities
   - Role management issues

4. **Price Feed**
   - Oracle manipulation vulnerabilities
   - Price update timing issues
   - Stale price data concerns

### Responsible Disclosure

We kindly ask you to:

- Allow us a reasonable amount of time to fix the issue before making any information public
- Make a good faith effort to avoid privacy violations, destruction of data, and interruption or degradation of our service
- Only interact with accounts you own or have explicit permission to test

### Safe Harbor

We consider security research conducted under this policy to be:

- Authorized concerning any applicable anti-hacking laws
- Authorized concerning any relevant anti-circumvention laws
- Exempt from restrictions in our Terms of Service that would interfere with conducting security research
