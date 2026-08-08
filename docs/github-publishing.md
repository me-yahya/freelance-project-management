# Publishing This Rails App On GitHub

## Before The First Commit

Run the test suite:

```bash
bin/rails test
```

Check what Git will include:

```bash
git status --short
git status --short --ignored
```

Do not commit:

- `config/master.key`
- `.env*`
- `log/*`
- `tmp/*`
- `storage/*.sqlite3`
- `script/certs/*`

Do commit:

- `Gemfile`
- `Gemfile.lock`
- `db/schema.rb`
- `db/migrate/*`
- app, config, test, and docs files

## Create The GitHub Repo

Create an empty repository on GitHub. Do not add a README from GitHub because
this project already has one.

Then run:

```bash
git add .
git status --short
git commit -m "Initial Rails freelance manager app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

## Ruby/Rails Notes

Ruby projects normally commit `Gemfile.lock` for applications. That gives other
developers and GitHub Actions the same gem versions.

Rails apps do not commit local databases, uploaded files, logs, temporary files,
or secret keys. New developers create their own local database with:

```bash
bin/rails db:prepare
bin/rails db:seed
```

If someone does not want to use `work.local`, they can run:

```bash
LOCAL_APP_HOST=localhost bin/rails server
```

and open:

```text
http://localhost:3000
```
