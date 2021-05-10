const settings = JSON.parse(localStorage.getItem(__prefix('__palette')));
const scheme = settings?.color.scheme || (matchMedia('(prefers-color-scheme: dark)').matches ? 'slate' : 'default' );

document.body.setAttribute('data-md-color-scheme', scheme);
