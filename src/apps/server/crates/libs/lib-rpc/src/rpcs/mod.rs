use crate::router::RpcRouter;

pub mod agent_rpc;
pub mod conv_rpc;
pub mod journal_rpc;
pub mod exchange_rpc;
pub mod tag_rpc;
mod macro_utils;
mod prelude;

pub fn all_rpc_router() -> RpcRouter {
	RpcRouter::new()
		.extend(agent_rpc::rpc_router())
		.extend(conv_rpc::rpc_router())
}
