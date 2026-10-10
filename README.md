# NIKKE Union Raid Optimizer

A web page that helps you plan your daily Union Raid runs in NIKKE: Goddess of
Victory. You record the teams you've tested and how much damage each one did.
The page then picks the three teams with the highest combined damage that don't
share a single Nikke, since each Nikke can only be used once a day.

It can also read a battle result screenshot for you, so you don't have to type
every name and damage number by hand.

## Using it

Open the site in your browser. Everything you enter is saved in that browser,
so it's still there when you come back. It isn't shared with other people or
synced to your other devices.

### Adding a team

1. In **Add Team**, pick the boss the team was used on. Pick **— Any** for a
   team that can be sent against any boss.
2. Choose up to five Nikkes and type the damage each one did. You can type
   the damage the way the game shows it (`4.795.896.805`), as a plain number
   (`4795896805`) or in short form (`4.8B`, `4800M`).
3. The total is added up for you. If you only know the team's total, leave the
   per-unit damage empty and type it under **Override Score** instead.
4. Click **Add Team**. The team shows up in the **Team Roster**.

### Reading a screenshot

1. Open **OCR Authentication**, enter the username and password your union
   leader gave you, and click **Save**. You only need to do this once per
   browser.
2. Drop a battle result screenshot onto the upload box, or click it to choose
   a file (5 MB at most), then click **Scan Screenshot**.
3. Check the names and damage it found and fix any mistakes. You can remove
   rows that don't belong.
4. Click **Apply to Form**. This fills in **Add Team**, so pick the boss and
   click **Add Team** as usual.

### Finding the best lineup

- **Lock** the teams you've already used today. Locked teams always stay in
  the lineup, and the remaining runs are planned around them.
- Under **Dead Bosses**, mark the bosses that have already been defeated.
  Teams for those bosses are skipped, while **— Any** teams can still be used.
  Locked teams still count, because they were used before the boss died.
  Click a boss again to mark it alive, for example when a new set of bosses
  starts.
- **Required Boss** makes sure one of the three runs goes to that boss. With
  **Prioritize strongest team for this boss** turned on, your best team for
  that boss is always picked, even if that lowers the total damage.
- Click **Find Optimal Lineup**. The result shows each run, which boss it's
  for and the combined damage.

The **Conflicts** counter in the roster shows how many Nikkes appear in more
than one team. That's normal, and the optimizer takes care of it.

## Privacy

- Your teams and the dead boss list are stored only in your browser.
- The OCR login is also stored in your browser, in plain text. Don't use it on
  a shared computer.
- Screenshots you scan are sent to the site's Cloudflare Worker and read by
  Cloudflare Workers AI. The site doesn't keep them.
- Each scan request is logged for the site owner: time, IP address, country,
  browser, username, whether it worked, image size and how long it took.
  Scans with a wrong login are logged too.

## Hosting your own copy

The site runs as a Cloudflare Worker. You need a
[Cloudflare account](https://dash.cloudflare.com/sign-up) and
[Node.js](https://nodejs.org/), which provides `npx` to run Wrangler,
Cloudflare's command-line tool.

```bash
git clone https://github.com/nosini/Nikke.git
cd Nikke

# Log in to Cloudflare
npx wrangler login

# Create the database for the scan log
npx wrangler d1 create ocr-logs
```

Before going on, edit `wrangler.toml`:

- Replace `database_id` with the ID that `d1 create` printed.
- To serve the site on your own domain, uncomment the `[[routes]]` block and
  fill in a domain you have on Cloudflare. Without it, the site uses the
  `workers.dev` address Wrangler gives you.

Then set up the database and the two logins, and publish the site:

```bash
npx wrangler d1 execute ocr-logs --remote --file=./schema.sql

npx wrangler secret put OCR_USER    # your own login
npx wrangler secret put OCR_PASS
npx wrangler secret put UNION_USER  # the login you share with your union
npx wrangler secret put UNION_PASS

npx wrangler deploy
```

Both logins can use the screenshot scanner. Having two lets you tell your own
scans apart from your union's in the log. Share the union username and
password with your members. They don't need a Cloudflare account.

Scanning uses Meta's Llama 3.2 Vision model on Workers AI, which counts
towards your Workers AI usage. The first scan accepts Meta's license for that
model on your account.

Maintenance tasks, such as adding new Nikkes and reading the scan log, are
covered in the [development guide](docs/development.md).

## License

[GNU Affero General Public License v3.0](LICENSE)
