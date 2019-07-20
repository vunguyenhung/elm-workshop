import Octokit from '@octokit/rest';

const octokit = new Octokit();

function buildQuery({ query, queryMinStars, queryIn, queryUser }) {
  const optional = (transformer) => (param) => param ? transformer(param) : (param) => param;
  const withMinStars = (stars) => (query) => `${query}+stars:>=${stars}`;
  const withIn = (str) => (query) => `${query}+in:${str}`;
  const withUser = (str) => (query) => `${query}+user:${str}`;
  const withLanguage = (language) => (query) => `${query}+language:${language}`;
  const build = (...transformers) => {
    return (query) => {
      return transformers.reduce((acc, transform) => transform(acc), query);
    };
  };

  return build(
    withMinStars(queryMinStars),
    optional(withIn)(queryIn),
    optional(withUser)(queryUser),
    withLanguage('elm'),
  )(query);
}

function searchRepos(query) {
  return octokit.search.repos({
    q: buildQuery(query),
    sort: 'stars',
    order: 'desc',
  }).then(({ data }) => data);
}

export {
  searchRepos,
};
