import { Button, LabeledList, NumberInput, Section } from '../components';

import { BooleanLike } from 'common/react';
import { Window } from '../layouts';
import { useBackend } from '../backend';
import { getGasLabel } from '../constants';

type Data = {
  filter_types: Filter[];
  on: BooleanLike;
  rate: number;
  max_rate: number;
};

type Filter = {
  enabled: BooleanLike;
  gas_id: string;
};

export const AtmosFilter = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { filter_types = [], on, rate, max_rate } = data;

  return (
    <Window width={440} height={240}>
      <Window.Content>
        <Section
          buttons={
            <Button
              icon={on ? 'power-off' : 'times'}
              content={on ? 'Вкл' : 'Выкл'}
              selected={on}
              onClick={() => act('power')}
            />
          }
          fill
          title="Фильтр">
          <LabeledList>
            <LabeledList.Item label="Скорость передачи">
              <NumberInput
                animated
                value={rate}
                width="63px"
                unit="Л/с"
                minValue={0}
                maxValue={max_rate}
                onDrag={(_, value) =>
                  act('rate', {
                    rate: value,
                  })
                }
              />
              <Button
                ml={1}
                icon="plus"
                content="Максимум"
                disabled={rate === max_rate}
                onClick={() =>
                  act('rate', {
                    rate: 'max',
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Фильтры">
              {filter_types.map(({ enabled, gas_id }, index) => (
                <Button
                  key={index}
                  icon={enabled ? 'check-square-o' : 'square-o'}
                  selected={enabled}
                  onClick={() =>
                    act('toggle_filter', {
                      val: gas_id,
                    })
                  }>
                  {getGasLabel(gas_id)}
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
