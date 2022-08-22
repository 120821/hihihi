<p align="center">
  <img src="https://homeland.ruby-china.org/images/text-logo.svg" width="400">
  <p align="center">Open source discussion website.</p>
  <p align="center">开源的论坛／社区网站系统，基于 <a href="https://ruby-china.org">Ruby China</a> 发展而来。</p>
  <p align="center">
    <a href="https://github.com/ruby-china/homeland/actions">
      <img src="https://github.com/ruby-china/homeland/workflows/Test/badge.svg">
    </a>
  </p>
</p>

## Usage

- [DEPLOYMENT GUIDE](https://homeland.ruby-china.org)
- [EXAMPLE](https://homeland.ruby-china.org/expo)
- [RELEASE NOTES](https://github.com/ruby-china/homeland/releases)
- [CONTRIBUTE GUIDE](https://github.com/ruby-china/homeland/blob/master/CONTRIBUTE.md)

## Quick Start For Developer 开发人员快速上手

### Env 环境

1.install asdf: refer to: https://github.com/asdf-vm/asdf
2.install ruby,nodejs,postgres,redis via asdf:

```
cd <homeland>
asdf install
```

3.install bundler: 2.3.3

```
gem install bundler -v 2.3.3
```

4.install npm,yarn,webpack:

```
npm install -g yarn
yarn install
bundle exec rails webpacker:install
```

5.change .env.local:

```
DATABASE_URL=postgres://admin:88888888@172.17.0.1:5433/homeland
```

6.create secret credential:

```
EDITOR='vim' bundle exec rails credentials:edit
```

7.run migration:

```
rake db:create
rake db:migrate
```

8.change webpacker server port ( don't be the same with rails port):

```
# config/webpacker.yml
    port: 3030
```

9.run server:

```
bundle exec rails s -p 3000           # port 3000
bundle exec bin/webpack-dev-server    # port 3030
```

10.open browser: "http://localhost:3000"

## License

Released under the MIT license:

- [www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)
