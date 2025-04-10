# Recomendador de Filmes 🎬

Este aplicativo foi desenvolvido para recomendar filmes com base no tema ou no tipo de filme desejado pelo usuário. Ele utiliza o modelo Gemini 2.0 da Google para gerar recomendações personalizadas e também integra reconhecimento de voz para permitir que os usuários interajam de forma mais intuitiva.

## Tema Escolhido

O tema do aplicativo é **Recomendação de Filmes por Gênero ou Caracteristicas**. O aplicativo permite que o usuário informe seu tema ou o tipo de filme desejado (como "comédia", "drama", "ação", etc.) para receber sugestões de filmes que se encaixam nesse tema. A interação pode ser feita tanto por texto quanto por voz, tornando a experiência ainda mais dinâmica.

### Exemplos de Temas:

- **Comédia**: Filme divertido para descontrair.
- **Romance**: Filme leve para um clima romântico.
- **Ação**: Filme de aventura e ação com cenas emocionantes.
- **Drama**: Filme com histórias intensas e emocionais.

## Prompt Utilizado

O prompt utilizado para gerar as recomendações de filmes é o seguinte:

```text
Quero assistir "$tema".

Com base nesse tema, recomende até 3 filmes que combinem com esse tipo de tema. 
Inclua nome do filme, breve sinopse e por que ele é adequado para o tema solicitado. Use uma linguagem leve e acolhedora. 
Pode misturar clássicos e novidades, e variar entre gêneros como comédia, drama, aventura ou romance.
