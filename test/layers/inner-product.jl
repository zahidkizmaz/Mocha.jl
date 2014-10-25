############################################################
# Prepare Data for Testing
############################################################
left_dim   = 50
inner_dims = (2,3)
right_dim  = 100
eps        = 1e-10

X = rand(left_dim, inner_dims...)
W = rand(inner_dims..., right_dim)
b = rand(right_dim)

############################################################
# Setup
############################################################
layer  = InnerProductLayer(; output_dim=right_dim, tops = String["result"], bottoms=String["input"])
inputs = Blob[Blob("input", X)]
state  = setup(layer, inputs)

@test size(state.W.data) == size(W)
@test size(state.b.data) == size(b)
state.W.data[:] = W
state.b.data[:] = b

forward(state, inputs)

X2 = reshape(X, left_dim, prod(inner_dims))
W2 = reshape(W, prod(inner_dims), right_dim)
b2 = reshape(b, 1, right_dim)
res = X2*W2 .+ b2

@test all(-eps .< state.blobs[1].data - res .< eps)