+++
title       = "Criando rapidamente um site pessoal com Hugo e Docker"
linktitle   = "Criando rapidamente um site pessoal com Hugo e Docker"
description = "Como eu criei e deployei rapidamente este site com Hugo e Docker"
date        = "2019-04-25"
comments    = true
keywords    = ["hugo", "golang", "go", "docker", "deploy"]
toc         = true

[author]
name = "Mateus Felipe Cordeiro Caetano Pinto"
+++

## Introdução

Criar um site pessoal é uma tarefa trivial. Existem diversas opções no mercado, desde opções para leigos totais, como o [Wix](https://pt.wix.com/), ou plataformas mais robustas (e, neste caso, de qualidade questionável), como o [Wordpress](https://wordpress.com/). No entanto, caso se queira maior flexibilidade e capacidade técnica, o mais comum é se recorrer a soluções mais técnicas. Ainda assim, parece ser um esforço demasiado e desnecessário gastar o seu tempo lidando com rotas, middlewares, requisições HTTP ou quaisquer outros aspectos técnicos que não se deseja ter que lidar apenas para um site pessoal, mesmo que você tenha o conhecimento necessário.

Diante disso, algumas alternativas se apresentam como tecnologias que tentam proporcionar o melhor de ambas as abordagens, isto é, garantir um *deploy* rápido e um *workflow* simples sem comprometer a flexbilidade técnica. A fim de implementar [meu site pessoal](mateusfccp.me), optei por uma dessas tecnologias, a saber, o [Hugo](https://gohugo.io/).

> Hugo is a static HTML and CSS website generator written in Go. It is optimized for speed, ease of use, and configurability. Hugo takes a directory with content and templates and renders them into a full HTML website.
>
> *— Readme do Hugo no Github [^1]*

[^1]: https://github.com/gohugoio/hugo/blob/master/README.md

De forma sucinta, o Hugo não é um servidor nem lida com aspectos relacionados a isso.[^2] Ele meramente gera arquivos estáticos com base em uma estrutura de arquivos e um arquivo de configuração. Para um site pessoal simples, como esse em que você está lendo, não é necessário mais do que isso. E ao descartar um banco de dados e uma estrutura de servidor, reduzimos o *overhead* consideravelmente e, consequentemente, os custos de infraestrutura. Some isso ao *deploy* agilizado que o [Docker](https://www.docker.com) oferece, e temos, rapidamente, uma página disponível na web.

[^2]: Apesar do Hugo não ser um servidor, o CLI do Hugo disponibiliza um comando para rodar um server localmente ([`hugo server`](https://gohugo.io/commands/hugo_server/)). Normalmente, este servidor é utilizado para um desenvolvimento mais rápido, já que o desenvolvedor não terá que se preocupar em servir os arquivos estáticos nem em recompilá-los a cada alteração.

Neste post, vou mostrar os passos que eu executei e, consequentemente, que você também pode exexecutar para subir fácil e rapidamente um site pesssoal na web com Hugo e Docker, tendo como estrutura o confiável serviço do [EC2 Container Service](https://aws.amazon.com/pt/ecs/).


## Instalando e Configurando o Hugo

O primeiro passo é instalar e configurar o Hugo. Não vou entrar em detalhes da instalação, porque é um processo simples e bem documentado [na página do Hugo](https://gohugo.io/getting-started/installing). Após a instalação, a [CLI](https://gohugo.io/commands/) do Hugo estará disponível para a criação de conteúdo.

Para criar um novo site, basta rodar `hugo new site <nome>`. Uma pasta com o nome que foi passado será criado, com a seguinte estrutura:

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

Como queremos um *deploy* rápido, podemos ignorar as pastas `archetypes`, `data`, `layouts` e `static`[^8]. Elas podem ser deletadas, caso você queira; o Hugo simplesmente vai usar os *defaults*. A partir de agora, vamos nos preocupar em [instalar um tema](#instalando-um-tema) e [configurar nosso site](#configurando-o-site).

[^8]: Uma explicação detalhada da estrutura de arquivos pode ser encontrada na [documentação](https://gohugo.io/getting-started/directory-structure/).

Caso você queira fazer o controle de versão do seu site (o que eu recomendo), agora é um bom momento para fazer o *commit* inicial. Inicialize o repositório local com `git init`, adicione o *remote* do seu repositório e suba o esqueleto gerado pelo Hugo.

### Instalando um Tema

Você não precisa de um tema para fazer um site. No entanto, você vai querer um. E instalar um tema no Hugo é extremamente fácil. Simplesmente copie ele para a pasta `themes` e modifique o arquivo de configuração para usar o tema instalado! Além disso, o Hugo possui uma [galeria de temas](https://themes.gohugo.io/) em seu site para ajudar você a escolher o que se encaixa melhor com o perfil de seu site!

Para o meu site, escolhi o tema [hello-friend-ng](https://github.com/rhazdon/hugo-theme-hello-friend-ng "hello-friend-ng"). Para instalar o tema, `git submodule add https://github.com/rhazdon/hugo-theme-hello-friend-ng.git`. Desta forma, o tema estará associado ao seu site no controle de versão, ao mesmo tempo que você poderá atualizá-lo facilmente quando necessário com um simples `git pull`.

{{<aside note>}}
Apesar de haver vários temas na galeria, talvez nenhum deles se encaixe com o seu site. Diante dessa situação, você pode criar o seu próprio tema ou modificar um desses existentes. Apesar de escolher o tema citado acima, [acabei alterando ele para melhor se encaixar às minhas necessidades](https://github.com/mateusfccp/mateusfccp.me-hugo "Meu Tema"). No entanto, o foco deste post é agilidade, então não faz parte do escopo mostrar como criar ou alterar temas no Hugo. Caso você se interesse por isso, o processo está bem explicado na [documentação do Hugo](https://gohugo.io/themes/creating/).
{{</aside>}}

### Configurando o Site

Após instalar o tema, podemos começar a configurar o site através do arquivo `config.toml`, na raíz do site.[^3] [^4] A documentação do Hugo contém uma descrição detalhada de cada parâmetro configurável, e é possível que o tema que você instalou possua parâmetros personalizado. Alguns parâmetros, no entanto, são comuns e costumam estar em todos os sites.

[^3]: O arquivo de configuração é gerado, por padrão, como TOML. No entanto, é possível configurar o seu site com YAML e Json, como apontado [na documentação](https://gohugo.io/getting-started/configuration/#configuration-file).

[^4]: Alternativamente, você pode passar um arquivo de configuração arbitrário através do argumento `--config` ao compilar ou servir o seu site.

* `baseurl`: *Hostname* da raíz do seu site. No meu caso, `http://mateusfccp.me`.
* `theme`: O nome do tema para ser compilado com seu site, conforme [seção anterior](#instalando-um-tema).
* `title`: Título do site.
* `description`: Descrição do seu site (usado nos [metadados](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta) do site).
* `author.name`: Autor do site (também usado nos metadados).
* `keywords`: Palavras-chave relacionadas com o seu site (também usado nos metadados).

Lógicamente, este é apenas um subconjunto comum de dezenas de possibilidades de configuração, e, normalmente, o suficiente para começar. Você pode consultar [a documentação do Hugo](https://gohugo.io/getting-started/configuration) ou do tema que você escolheu para mais possibilidades de configuração, como [menus](https://gohugo.io/content-management/menus/), [suporte a várias línguas](https://gohugo.io/content-management/multilingual/), [comentários](https://gohugo.io/content-management/comments/) etc.

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