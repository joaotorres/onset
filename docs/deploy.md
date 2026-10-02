# Deploying

Kamal to the Hostinger VPS that already runs done (done.joaotorr.es) and
linkpass. The app and kamal-proxy share the host. There is no database
accessory: the four SQLite databases live on a Docker volume. Deploys are run
by hand from this Mac. Why this shape: ~/Projects/TOOLCHAIN.md, Deployment,
and SPEC.md section 13.

## First deploy

1. **Point onset.joaotorr.es at the VPS.** In the Dreamhost panel for
   joaotorr.es add an `A` record `onset` with the IPv4 address that
   done.joaotorr.es resolves to (`dig +short done.joaotorr.es`). No `AAAA`
   record, done has none. Wait until `dig +short onset.joaotorr.es` returns
   the address: kamal-proxy requests the Let's Encrypt certificate during
   setup and fails if DNS does not resolve yet.

2. **Skip provisioning.** Docker and kamal-proxy are already on the host from
   the done deploy. Inbound 80 and 443 are open because done serves on them.
   This app only registers its own host with the proxy, so nothing about the
   other apps changes.

3. **Store the registry secret in the Keychain, once.** `.kamal/secrets`
   reads it at deploy time with `security find-generic-password`, so nothing
   is exported and nothing is written to disk. The command prompts for the
   value.

   ```
   security add-generic-password -a "$USER" -s onset-registry-pat -w
   ```

   The value is a GitHub personal access token (classic) with the
   `write:packages` scope, the same one done uses. The image goes to GitHub
   Container Registry and the package is private by default.

   `RAILS_MASTER_KEY` needs nothing: `.kamal/secrets` reads
   `config/master.key` directly. The first deploy of a login session may
   raise a Keychain prompt. Choose "Always Allow".

4. **Log in to the registry.**

   ```
   bin/kamal registry login
   ```

5. **Set up.** Builds the image, starts the app and registers the host with
   kamal-proxy, which then obtains the certificate. The container entrypoint
   runs `db:prepare` on boot, which creates and migrates all four SQLite
   databases on the `onset_storage` volume.

   ```
   bin/kamal setup
   ```

## Checking it works

```
curl https://onset.joaotorr.es/up
bin/kamal app exec 'bin/rails runner "puts SolidQueue::Process.count"'
```

The first prints a 200 page. The second prints at least 1: the Solid Queue
supervisor running inside Puma.

Then open https://onset.joaotorr.es/, create a game and join it from a phone.
Cards appearing on the board when the phone claims a Set confirms Action
Cable works through the proxy.

## Redeploying

```
bin/kamal deploy
```

No exports: `.kamal/secrets` fetches everything it needs. The old and new
containers overlap briefly during a deploy and share the SQLite files. That
is safe: Rails opens SQLite in WAL mode, and games are short lived anyway.

## Logs

```
bin/kamal logs          # the app, followed
bin/kamal proxy logs    # kamal-proxy, including certificate issuance
bin/kamal console       # a Rails console in the running app
bin/kamal shell         # a shell in the running app, storage/ has the databases
```

## Backups

None. The databases hold live game state only, nothing worth keeping between
games. If that changes, copy `storage/*.sqlite3` off the volume from
`bin/kamal shell` or add a nightly job.

## Not covered here

There is no staging environment and no CI deploy.
