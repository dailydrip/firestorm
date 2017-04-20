![Firestorm](./apps/firestorm_web/assets/static/images/firestorm-logo.png)
### An open-source forum engine, with an Elixir+Phoenix backend and an Elm frontend.
#### A community-funded project from [DailyDrip](https://www.dailydrip.com).

[![Build Status](https://semaphoreci.com/api/v1/dailydrip/firestorm/branches/master/badge.svg)](https://semaphoreci.com/dailydrip/firestorm)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/dailydrip/firestorm.svg)](https://beta.hexfaktor.org/github/dailydrip/firestorm)


This is the Firestorm Forum project.  We've just reached the "initial
dogfooding" phase and you can view the first deployed version at
<http://firestorm-dogfood.herokuapp.com>.

[The design document](design/README.md) is a good place to start reading if
you're unfamiliar with the project.

## Patrons

This project was funded by [a
Kickstarter](https://www.kickstarter.com/projects/1003377429/firestorm-an-open-source-forum-in-phoenix-from-eli).

All of the patrons that made it possible are listed in [the PATRONS
file](PATRONS.md).

## Code

This is an umbrella app consisting of [`firestorm_data`](./apps/firestorm_data)
and [`firestorm_web`](./apps/firestorm_web).

## Features

At present, we're wrapping up [the initial design phase](design/README.md). Having
said that, here are the planned features and their status:

- [x] [Continuous Integration](https://semaphoreci.com/dailydrip/firestorm)
  - We're using Semaphore CI for this
- [ ] Continuous Deployment
  - With releases, via [distillery](https://github.com/bitwalker/distillery)
  - For now, we've got Semaphore pushing to
    <http://firestorm-dogfood.herokuapp.com> after each successful build of
    master.
- [x] OAuth
  - At present, we only support GitHub. We'll support a lot more services in the
    future, but until we're happy with the state of the rest of the dogfooding
    session we'll stick with GitHub.
- [ ] Email (first class!)
  - The goal here is to be a fantastic replacement for Google Groups
- [x] Forums
- [x] Topics
  - [ ] Stickies
- [x] Posts
- [ ] Personal Messaging
- [ ] Tags
- [ ] Search
- [ ] Slack Integration
- [ ] Plugin System

## Configuration

### S3

Attachments are stored on S3. Consequently, you will need to create an S3 bucket
to store them, as well as an API user that can write to it and list all of your
buckets, and configure the bucket for CORS.

You also need to set 4 environment variables:

```sh
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=XXXX
export AWS_S3_BUCKET=XXXX
export AWS_S3_REGION=XXXX
```

#### CORS configuration

Here's an example CORS configuration:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <CORSRule>
    <AllowedOrigin>http://localhost:4000</AllowedOrigin>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
  </CORSRule>
  <CORSRule>
    <AllowedOrigin>http://firestorm-dogfood.herokuapp.com</AllowedOrigin>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
  </CORSRule>
</CORSConfiguration>
```

## License

Firestorm is [MIT Licensed](./LICENSE).
