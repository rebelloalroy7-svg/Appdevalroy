import React from 'react';
import renderer from 'react-test-renderer';
import MyButton from './Button';

test('matches snapshot', () => {
  const tree = renderer
    .create(<MyButton title="Snapshot Test" />)
    .toJSON();

  expect(tree).toMatchSnapshot();
});
