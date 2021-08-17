use chrono::Utc;
use serde_derive::{Deserialize, Serialize};
use svc_agent::{
    mqtt::{
        IntoPublishableMessage, OutgoingEvent, OutgoingEventProperties, ShortTermTimingProperties,
    },
    AccountId,
};

use crate::config::Config;

const CONFERENCE_API_VERSION: &str = "v2";

#[derive(Debug, Default, Serialize)]
struct Payload {
    #[serde(skip_serializing_if = "Option::is_none")]
    duration: Option<u64>,
}

impl Payload {
    fn new() -> Self {
        Default::default()
    }

    fn set_duration(&mut self, duration: u64) -> &mut Self {
        self.duration = Some(duration);
        self
    }
}

#[derive(Debug, Deserialize, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Event {
    #[serde(rename = "metric.pull")]
    MetricPull,
    #[serde(rename = "system.vacuum")]
    SystemVacuum,
    #[serde(rename = "room.notify_opened")]
    RoomNotifyOpened,
    #[serde(rename = "system.close_orphaned_rooms")]
    CloseOrphanedRooms,
}

impl Event {
    pub(crate) fn into_message(self, config: &Config) -> Box<dyn IntoPublishableMessage + Send> {
        let mut payload = Payload::new();

        if let Some(duration) = config.events.get(&self) {
            payload.set_duration(*duration);
        }

        match self {
            Self::MetricPull => {
                let props = build_props("metric.pull");
                Box::new(OutgoingEvent::broadcast(payload, props, "events"))
            }
            Self::SystemVacuum => Box::new(OutgoingEvent::multicast(
                payload,
                build_props("system.vacuum"),
                &svc_account(config, "conference"),
                CONFERENCE_API_VERSION,
            )),
            Self::RoomNotifyOpened => Box::new(OutgoingEvent::multicast(
                payload,
                build_props("room.notify_opened"),
                &svc_account(config, "conference"),
                CONFERENCE_API_VERSION,
            )),
            Self::CloseOrphanedRooms => Box::new(OutgoingEvent::multicast(
                payload,
                build_props("system.close_orphaned_rooms"),
                &svc_account(config, "conference"),
                "v1",
            )),
        }
    }
}

fn build_props(label: &'static str) -> OutgoingEventProperties {
    let timing = ShortTermTimingProperties::new(Utc::now());
    OutgoingEventProperties::new(label, timing)
}

fn svc_account(config: &Config, label: &'static str) -> AccountId {
    AccountId::new(label, &config.svc_audience)
}
