import { Elm } from './Main.elm';
import { searchRepos } from './github';

function main() {
  const elmApp = Elm.Main.init({
    node: document.querySelector('main'),
  });

  elmApp.ports.githubSearch.subscribe((query) => {
    searchRepos(query)
      .then(elmApp.ports.githubResponse.send)
      .catch(elmApp.ports.githubResponse.send);
  });
}

main();
