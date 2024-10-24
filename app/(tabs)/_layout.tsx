import { Tabs } from 'expo-router';
import React from 'react';
import { Feather, Fontisto } from '@expo/vector-icons';

export default function TabLayout() {

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarShowLabel: false,
        tabBarActiveTintColor: 'black',
        tabBarInactiveTintColor: '#95a5a6'
      }}>
      <Tabs.Screen
        name="index"
        options={{
          tabBarIcon: ({ color }) => (
            <Feather name="unlock" size={30} color={color} />
          )
        }}
      />
      <Tabs.Screen
        name="impulse"
        options={{
          tabBarIcon: ({ color }) => (
            <Fontisto name="heartbeat-alt" size={30} color={color} />
          )
        }}
      />
      <Tabs.Screen
        name="analytics"
        options={{
          tabBarIcon: ({ color }) => (
            <Feather name="trending-up" size={30} color={color} />
          )
        }}
      />
    </Tabs>
  );
}
