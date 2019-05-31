+++
title       = "Quickly deploying a personal website with Hugo and Docker"
linktitle   = "Quickly deploying a personal website with Hugo and Docker"
description = "How I quickly deployed this website with Hugo and Docker"
date        = "2019-05-06"
comments    = true
keywords    = ["hugo", "golang", "go", "docker", "deploy"]
toc         = true
draft       = true

[author]
name = "Mateus Felipe Cordeiro Caetano Pinto"
+++

	
## Introduction

Making a personal website is a trivial task. There are plenty options out there, from total newbies options, like [Wix](https://wix.com), to more robust (and, in this case, with a questionable quality), like [Wordpress](https://wordpress.com/). However, if you want greater flexibility, it's usual to appeal to more technical solutions. Even so, it seems to be a overengineering to waste your time dealing with routes, middlewares, HTTP requests or any other technical aspect that you probably don't want to deal when making a simple personal website, even if you have the know-how.

Considering this, some alternatives presents themselves as techologies that attempt to provide the better of both approaches, namely, to ensure a quick deploy and a simple workflow, without compromising techinal flexibility. In order to implement [my personal website](mateusfccp.me/en), I've opted for one of these, [Hugo](https://gohugo.io/).

> Hugo is a static HTML and CSS website generator written in Go. It is optimized for speed, ease of use, and configurability. Hugo takes a directory with content and templates and renders them into a full HTML website.
>
> *— Hugo's Readme on Github [^1]*

[^1]: https://github.com/gohugoio/hugo/blob/master/README.md

Succintly, Hugo is not a server nor deals with server related aspects.[^2] Instead, it generates static files based on your source directory strucutre and a configuration file. For a simple personal website, like this one your are now, this is enough. Also, by not having to use any database and server structure, we reduce considerably the overhead and, hence, the infrastructure costs. Add to this the straightforward deploy that [Docker](https://www.docker.com) offers and we are able to have a page on web in no time.

[^2]: Although Hugo is not a server, Hugo CLI provides a command to locally run a server ([`hugo server`](https://gohugo.io/commands/hugo_server/)). Usually, this server is used for a faster development, as the developer won't have to worry about serving the static files on it's localhost, nor recompiling it when they change.

In this post, I'm going to show the steps I took and, consequently, that you may also take to easily and quickly deploy a personal website on web with Hugo and Docker, using [EC2 Container Service](https://aws.amazon.com/ecs/) as it's infrastructure.


## Installing and setting Hugo

The first step is to install and set up Hugo. I won't get deep on installation process because it is simple enough and well documented on [Hugo's website](https://gohugo.io/getting-started/installing). After installing, Hugo's [CLI](https://gohugo.io/commands/) will be available for us to make our content.

To make a new site, simply run `hugo new site <name>`. A new folder will be created with the inputted name, and the directory will have the following structure:


```
.
├── archetypes
│   └── default.md
├── config.toml
├── content
├── data
├── layouts
├── static
└── themes
```

We are aiming for a **quick** deploy, so we may ignore `archetypes`, `data`, `layouts` and `static`[^8] for now. You may also delete them if you want, as Hugo wil simply use it's defaults. Now, we only need to worry about [installing a theme](#installing-a-theme) and [configuring the site](#configuring-the-site).

[^8]: Detailed info about directory structure may be found in the [documentation](https://gohugo.io/getting-started/directory-structure/).

If you want to make your site version control (which I highly recommend), now is a good moment to initialize the repository and push the initial commit. Run `git init`, add your repository remote and push the newly created skeleton.

### Installing a Theme

You don't really need a theme to make a site with Hugo. However, you will want one. Installing a theme on Hugo is extremely straightforward. You only need to copy it to `theme` directory and set the config file to use it. Furhtermore, Hugo has a [theme gallery](https://themes.gohugo.io) to help you to choose a theme that better fits on your particular needs.

For my site I chose the [hello-friend-ng](https://github.com/rhazdon/hugo-theme-hello-friend-ng "hello-friend-ng") theme. I installed it by running `git submodule add https://github.com/rhazdon/hugo-theme-hello-friend-ng.git`. This way, the theme will be attached to my site repository as a submodule, and I will be able to update it easily with `git pull`.

{{<aside note>}}
Although there's a plenty of themes on the gallery, maybe none of them fits exactly your needs. If this is the case, you can make your own theme from scratch or modify one of the existents. Although I did choose the aforementioned theme, [I ended up modifying it to better fit my needs](https://github.com/mateusfccp/mateusfccp.me-hugo "My Theme"). However, the focus of the post is quickness, so it's not part of the scope show how to make/modify themes. If you want to know more about, the proceeding is well explained [on the documentation](https://gohugo.io/themes/creating/). 
{{</aside>}}

### Configuring the Site

After the theme is installed, we can start to configure our site through `config.toml`, which is on directory root.[^3] [^4] Hugo's documentation has a detailed description of each configurable parameter, and it's possible that the theme you installed provides custom parameters. Some of them, however, are common and are usually on every site.

[^3]: The config file is generated, by default, as TOML. However, it's possible to config your site with YAML or Json, as pointed on [the documentation](https://gohugo.io/getting-started/configuration/#configuration-file).

[^4]: Alternatively, you may pass your config file by specifying the `--config` option when compiling your site.

* `baseurl`: *Hostname* of your site. In my case, `http://mateusfccp.me`.
* `theme`: Your theme's name, as in `themes` folder. See [previous section](#installing-a-theme).
* `title`: Your site's title.
* `description`: Description of your site (used on [metadata](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta).
* `author.name`: Your site's author (also used on metadata).
* `keywords`: Keywords related to your site content (also used on metadata).

Obviously, this is just a commonly used subset of dozens configuration options, and, usually, the enough to start. You can check [Hugo documentation](https://gohugo.io/getting-started/configuration) or your theme's one for more parameters, like [menus](https://gohugo.io/content-management/menus/), [multilingual support](https://gohugo.io/content-management/multilingual/), [comments](https://gohugo.io/content-management/comments/) etc.

## Produzindo Conteúdo

O Hugo já está devivamente instalado e configurado. Antes de rodar o compilador ou o server, no entanto, vamos precisar de algum conteúdo.

### Criando uma Página

O Hugo simplifica a criação de conteúdo através do comando [`hugo new`](https://gohugo.io/commands/hugo_new/). Para criar o seu primeiro post, basta executar o comando: `hugo new posts/<slug>.md`.[^5] O *slug* é um identificador alfanumérico para seu conteúdo e, por padrão, é usado na construçao da *url*. Por exemplo, este post que você está lendo tem como diretório `content/posts/docker-and-hugo.md`, portanto a url é [{{< ref "docker-and-hugo" >}}]({{< ref "docker-and-hugo" >}})

[^5]: O Hugo lida com o [tipo de conteúdo](https://gohugo.io/content-management/types/), por padrão, com base no caminho do conteúdo, neste caso, `posts`. Outros tipos de conteúdo podem estar disponíveis dependendo da sua configuração e seu tema. Além disso, você pode especificar o tipo de conteúdo do arquivo no momento da criação com a flag `-k <kind>`.

O Hugo irá gerar um novo arquivo conforme o tipo de conteúdo especificado, que varia de tema para tema. No meu caso, o arquivo gerado tem o seguinte conteúdo:

```yaml
---
title: "Criando rapidamente um site pessoal com Hugo e Docker"
date: 2019-04-29T10:56:41-03:00
draft: true
toc: false
images:
tags:
  - untagged
---
```

Este cabeçalho se chama [*front matter*](https://gohugo.io/content-management/front-matter/), na terminologia do Hugo. O *front matter* é definido entre os delimitadores `---`[^6], e vão prover para o Hugo os dados necessários para a compilação correta dos arquivos. Apesar da estrutura criada prover os principais dados, há muitos outros que podem ser insertos no cabeçalho. Uma lista complete pode ser encontrada na [documentação](https://gohugo.io/content-management/front-matter/#front-matter-formats).

[^6]: Caso o cabeçalho use `---` como delimitadores, a configuração deverá ser escrita em YAML. Também serão aceitos os delimitadores `+++` para TOML e `{ }` para JSON. [<sup>[fonte]</sup>](https://gohugo.io/content-management/front-matter/#front-matter-formats)

Após o cabeçalho, vem o conteúdo propriamente dito. Conforme o nome do arquivo sugere, o conteúdo do Hugo é, por padrão, escrito em Markdown.[^7] Não faz parte do escopo deste post ensinar Markdown, então, se você chegou até aqui e ainda não sabe o que é, sinta-se livre para pesquisar e escrever o seu conteúdo da forma como melhor lhe aprouver.

[^7]: Markdown é o formato padrão para o conteúdo do Hugo, mas outros formatos são suportados, como `.org` e `.html`. Para mais informações, consulte a [documentação](https://gohugo.io/content-management/formats/).

### Compilando e Servindo o Conteúdo com a CLI

O Hugo provê, na sua CLI, funcionalidade tanto para a compilação dos arquivos estáticos, quando para serví-los. O comando `hugo` irá compilar o seu site, mandando os arquivos estáticos para a pasta `/public`, onde estarão prontos para serem servidos.

```
[mateusfccp@ArchPinto hugo]$ hugo
                   | EN | PT-BR  
+------------------+----+-------+
  Pages            | 11 |    11  
  Paginator pages  |  0 |     0  
  Non-page files   |  0 |     0  
  Static files     | 13 |    13  
  Processed images |  0 |     0  
  Aliases          |  1 |     0  
  Sitemaps         |  2 |     1  
  Cleaned          |  0 |     0  

Total in 71 ms
```

Na próxima seção vamos dar uma rápida olhada em como configurar um container Docker com *nginx* para servir os arquivos estáticos. No entanto, vale lembrar que, além do comando `hugo`, para compilar, há também o comando `hugo server`, que, como o nome sugere, em vez de compilar os arquivos para o diretório de *output*, roda um servidor para serví-los.[^9] Este servidor pode ou não ser utilizado em produção, mas sua maior utilidade se dá no desenvolvimento.

[^9]: Os arquivos, em vez de serem escritos no diretório de *output*, são armazenados na memória durante a execução do servidor, a não ser que ele não consiga fazer isso por qualquer motivo.

Ao rodar o servidor do Hugo, você se livra do trabalho de configurar um servidor local apenas para servir os arquivos estáticos, o que já economiza um tempo razoável no desenvolvimento. Não apenas isso, o servidor também observa o diretório do seu site para alterações. Isto significa que toda vez que você alterar um arquivo e salvá-lo, o servidor irá recompilá-lo instantaneamente e atualizar a página no navegador. Esta função acelera consideravelmente o desenvolvimento e a publicação de conteúdo.

## Servindo o Site com Docker

Desenvolver um site rapidamente não tem muito sentido se você perder um bom tempo configurando uma infraestrutura para que ele possa rodar. Por conta disso, escolhi usar um contâiner Docker para fazer rapidamente o *deploy* do site.

Como a única coisa que precisamos é servir arquivos estáticos, o *nginx* é uma opção viável. A [imagem oficial do nginx](https://hub.docker.com/_/nginx) é mais do que suficiente para servirmos o site, e não vamos alterar nem mesmo uma linha do arquivo de configuração do *nginx*. Nosso *Dockerfile* fica simples:

```Dockerfile
FROM nginx:alpine
COPY public /usr/share/nginx/html
```

Caso queira rodar o contâiner na sua máquina para testar, você pode fazê-lo facilmente com o comando

```
$ docker run --name mysite -d -p 80:80 mysite-instance
```
e acessá-lo através do navegador em http://localhost:80 (ou qual seja a porta que você configurou no argumento `-p`).

## Subindo o Site no Amazon ECS

Com o seu site e *Dockerfile* devidamente configurado, só resta subir ele para que todos possam acessar. O primeiro passo para isso é disponibilizar a sua imagem no [Docker Hub](https://docs.docker.com). Você pode criar quantos repositórios públicos quiser de graça, e o processo está descrito na [documentação](https://docs.docker.com/docker-hub/repos/). Se você preferir, pode também anexar o repositório do Docker Hub ao seu repositório Git. Desta forma, sempre que for feito um *commit* no Git, o Docker Hub irá puxar a versão mais atual e atualizar a imagem.

{{< aside warning >}}Os serviços da *Amazon Web Services* não são gratuitos em sua totalidade. Não me responsabilizo por quaisquer cobranças que você, eventualmente, venha a receber por ter seguido os passos a seguir.{{</aside>}}

Feito isso, abra o seu *console* da Amazon Web Sevices e procure pelo seviço **ECS**. Na página do serviço, clique em **Task Definitions**. Uma lista de *tasks* aparecerá (o que deverá estar vazia no momento). Clique no botão azul em cima da lista, escrito *Create new Task Definition*.

{{< post_image src="01.png" position="center"  >}}

Nesta página, quase todos os campos podem ficar como estão. Vamos fazer apenas duas mudanças. Primeiramente, dê um nome ao seu *task* através do campo *Task Definition Name*. Em seguida, desça até a seção chamada **Container Definitions** e clique no botão azul **Add container**. Uma tela se abrirá para você preencher outros dados.

{{< post_image src="02.png" position="center" >}}

Nesta tela, preencha o **Container name** com um nome arbitrário para o seu contâiner. O próximo campo, **Image**, deverá ter o nome da imagem conforme você especificou ao subir para o Docker Hub. Lembre-se de incluir o *namespace* da imagem, isto é, o nome da sua conta. No meu caso, ficou `mateusfccp/mateusfccp.me`.

Em *Memory Limits*, você define como será a alocação de memória para seu contâiner. Não vou entrar em detalhes aqui, recomendo que deixe um **Hard Limit** de **300MiB**, a não ser que veja necessidade de mais. No meu caso, por ser um site simples, foi o suficiente.

Role a página até onde está escrito **Port mappings**. Para que seu contâiner fique visível, é necessário mapear a porta 80 do contâiner para a porta 80 do *host*. Em **protocol**, deixe como está (tcp). Clique no botão **Add** para finalizar a configuração do contâiner, e em **Create** para finalizar a criação da *Task Definition*.

O próximo passo é criar um **Cluster**, isso é, uma máquina onde o seu contâiner vai rodar. Retorne à página principal do **Amazon ECS** e, no menu lateral, clique em **Clusters**. A página deverá mostrar todos os *clusters* configurados, se houver algum. Clique no botão azul **Create Cluster** e escolha entre o template de Linux ou Windows (💩).

Na página seguinte, configure o *cluster* conforme a sua necessidade. Eu, particularmente, após inserir o nome, optei por uma instância (**EC2 instance type**) *t2.micro*, já que ela possui um período de gratuidade, e deixei o restante dos campos com seus valores padrão. Clique em **Create**. Você verá uma página detalhando a criação do seu *cluster*.

Por fim, iremos anexar o *Task Definition* que criamos anteriormente ao *cluster* que acabamos de criar. Isso é feito atraveś de *services*. Volte novamente à página de *clusters*, onde agora você deverá ver o seu cluster recém criado, e clique nele.

Uma página com alguns dados do *cluster* irá aparecer, e várias abas, onde a primeira é *services*. Clique no botão azul abaixo da aba, **Create**.

{{< post_image src="03.png" position="center" >}}

Selecione a *Task Definition* e o *cluster* criados nos *dropdowns* respectivos. Nomeie o seu serviço e defina um número de *tasks* do seu serviço como 1. Todos os outros campos podem ser deixados como estão. Clique em **Next**.

As duas páginas seguintes podem ser ignoradas. Avance-as deixando-as como estão. A última página mostrará um resumo das configurações escolhidas. Confira esses dados, e se estiverem de acordo com suas necessidades, clique em **Create Service**. Seu site já está disponível para a web!

## Verificando os dados o seu contâiner

Após sua aplicação ter sido configurada com sucesso, provavelmente você vai querer ver informações acerca dela, principalmente o IP público, para que você possa configurar um domínio. Para fazer isso, acesse novamente o seu *cluster, e clique na aba **ECS Instances**. Clique na única instância que estará na lista, no primeiro campo (**Container Instance**), e você será direcionado a uma página como esta:

{{< post_image src="04.png" position="center" >}}

## Conclusão

Neste post, vimos o passo-a-passo para se instalar e configurar rapidamente um site pessoal, graças à combinação das tecnologias Hugo e Docker, ambas com a capacidade de agilizar o processo de desenvolvimento e infraestrutura.

Caso algo não tenha ficado claro ou haja alguma dúvida, fique à vontade para perguntar nos comentários abaixo. Se você ver algum erro no processo, fique à vontade também para informar, e irei editar o post.

Compart
	
