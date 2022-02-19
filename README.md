# Introducing Blockchain with Elixir

This code is an [Elixir](https://elixir-lang.org/) implementation of the blockchain described in [*Introducing Blockchain with Lisp* by Boro Sitnikovski](https://link.springer.com/book/10.1007/978-1-4842-6969-5). The code found in the book is written in [Racket](https://racket-lang.org/) and can be found at [this GitHub repo](https://github.com/Apress/introducing-blockchain-with-lisp).

Since I already know Racket for the most part and know Elixir, I wanted to implement the book's blockchain in Elixir to get more practice with Elixir, including:
* configuring an Elixir Mix project to have checks done by Credo and Dialyzer and developing a project from scratch,
* testing various styles of pattern matching structs,
* and struct-driven development.

For the most part, the code is quite close to what you will find in the Racket code. The major changes come from me making the code as idiomatic to Elixir as I could while retaining a similar structure and naming as the original Racket code. There are also some fixes in my Elixir implementation that fix just a few small issues or typos with the Racket code, as printed in the book.

## Dependencies

Outside of development tool oriented dependencies, the primary dependency is [ExCrypto](https://hexdocs.pm/ex_crypto/ExCrypto.html), which provides public and private keys, hashing, and digital signing.

## To use

Once you have the code local to your machine and Elixir installed, then all of `mix` is available to you. To get started:
1. Run `mix deps.get`
2. Run `mix check`
    - This will compile and run Credo, Dialyzer, and tests.

Note: use `mix.bat` on Windows.

## Notebooks

The exercises in the book and also the equivalent of the `main.rkt` file are implemented as [Livebook](https://livebook.dev/) notebooks, found in the notebooks directory. The notebook corresponding to `main.rkt` is `notebooks/main.livemd`.
1. [Install Livebook](https://livebook.dev/#install)
2. Run `livebook server` (if there's a port conflict with the default port of `8080` use the `--port` option to specify another port, e.g., `livebook server --port 8086`)
3. Navigate to the URL the Livebook application is running at (this is printed to the terminal after running the above command)
4. Open the `<wherever>/introducing-blockchain/notebooks/main.livemd` notebook
5. Go to **Settings** -> **Configure** and select **Mix standalone**. Then browse to `<wherever>/introducing-blockchain/` and click **Connect**.
    - This will connect the notebook to the Mix project, download all dependencies, and compile the project.

Now, you can execute the cells in the notebook. For example:

![image](https://user-images.githubusercontent.com/65685447/154183562-591249d9-2d26-403f-9de7-0caafab202ce.png)

